package big

/*
	Copyright 2021 Jeroen van Rijn <nom@duclavier.com>.
	Made available under Odin's BSD-2 license.

	An arbitrary precision mathematics implementation in Odin.
	For the theoretical underpinnings, see Knuth's The Art of Computer Programming, Volume 2, section 4.3.
	The code started out as an idiomatic source port of libTomMath, which is in the public domain, with thanks.
*/

import "core:mem"
import "core:intrinsics"
import rnd "core:math/rand"

// import "core:fmt"

/*
	TODO: Int.flags and Constants like ONE, NAN, etc, are not yet properly handled everywhere.
*/

/*
	Deallocates the backing memory of one or more `Int`s.
*/
int_destroy :: proc(integers: ..^Int) {
	integers := integers;

	for a in &integers {
		mem.zero_slice(a.digit[:]);
		raw := transmute(mem.Raw_Dynamic_Array)a.digit;
		if raw.cap > 0 {
			free(&a.digit[0]);
		}
		a = &Int{};
	}
}

/*
	Helpers to set an `Int` to a specific value.
*/
int_set_from_integer :: proc(dest: ^Int, src: $T, minimize := false, allocator := context.allocator) -> (err: Error)
	where intrinsics.type_is_integer(T) {
	src := src;

	if err = error_if_immutable(dest); err != nil { return err; }
	if err = clear_if_uninitialized(dest); err != nil { return err; }

	dest.flags = {}; // We're not -Inf, Inf, NaN or Immutable.

	dest.used  = 0;
	dest.sign = .Zero_or_Positive if src >= 0 else .Negative;
	src = abs(src);

	for src != 0 {
		dest.digit[dest.used] = DIGIT(src) & _MASK;
		dest.used += 1;
		src >>= _DIGIT_BITS;
	}
	zero_unused(dest);
	return nil;
}

set :: proc { int_set_from_integer, int_copy };

/*
	Copy one `Int` to another.
*/
int_copy :: proc(dest, src: ^Int, minimize := false, allocator := context.allocator) -> (err: Error) {
	/*
		If dest == src, do nothing
	*/
	if (dest == src) { return nil; }

	if err = error_if_immutable(dest);    err != nil { return err; }
	if err = clear_if_uninitialized(src); err != nil { return err; }

	/*
		Grow `dest` to fit `src`.
		If `dest` is not yet initialized, it will be using `allocator`.
	*/
	needed := src.used if minimize else max(src.used, _DEFAULT_DIGIT_COUNT);

	if err = grow(dest, needed, minimize, allocator); err != nil {
		return err;
	}

	/*
		Copy everything over and zero high digits.
	*/
	for v, i in src.digit[:src.used] {
		dest.digit[i] = v;
	}
	dest.used  = src.used;
	dest.sign  = src.sign;
	dest.flags = src.flags &~ {.Immutable};

	zero_unused(dest);
	return nil;
}
copy :: proc { int_copy, };

/*
	In normal code, you can also write `a, b = b, a`.
	However, that only swaps within the current scope.
	This helper swaps completely.
*/
int_swap :: proc(a, b: ^Int) {
	a := a; b := b;

	a.used,  b.used  = b.used,  a.used;
	a.sign,  b.sign  = b.sign,  a.sign;
	a.digit, b.digit = b.digit, a.digit;
}
swap :: proc { int_swap, };

/*
	Set `dest` to |`src`|.
*/
int_abs :: proc(dest, src: ^Int, allocator := context.allocator) -> (err: Error) {
	/*
		Check that src is usable.
	*/
	if err = clear_if_uninitialized(src); err != nil {
		return err;
	}
	/*
		If `dest == src`, just fix `dest`'s sign.
	*/
	if (dest == src) {
		dest.sign = .Zero_or_Positive;
		return nil;
	}

	/*
		Copy `src` to `dest`
	*/
	if err = copy(dest, src, false, allocator); err != nil {
		return err;
	}

	/*
		Fix sign.
	*/
	dest.sign = .Zero_or_Positive;
	return nil;
}

platform_abs :: proc(n: $T) -> T where intrinsics.type_is_integer(T) {
	return n if n >= 0 else -n;
}
abs :: proc{int_abs, platform_abs};

/*
	Set `dest` to `-src`.
*/
neg :: proc(dest, src: ^Int, allocator := context.allocator) -> (err: Error) {
	/*
		Check that src is usable.
	*/
	if err = clear_if_uninitialized(src); err != nil {
		return err;
	}
	/*
		If `dest == src`, just fix `dest`'s sign.
	*/
	sign := Sign.Zero_or_Positive;
	if z, _ := is_zero(src); z {
		sign = .Negative;
	}
	if n, _ := is_neg(src); n {
		sign = .Negative;
	}
	if (dest == src) {
		dest.sign = sign;
		return nil;
	}
	/*
		Copy `src` to `dest`
	*/
	if err = copy(dest, src, false, allocator); err != nil {
		return err;
	}

	/*
		Fix sign.
	*/
	dest.sign = sign;
	return nil;
}

/*
	Helpers to extract values from the `Int`.
*/
int_bitfield_extract_single :: proc(a: ^Int, offset: int) -> (bit: _WORD, err: Error) {
	return int_bitfield_extract(a, offset, 1);
}

int_bitfield_extract :: proc(a: ^Int, offset, count: int) -> (res: _WORD, err: Error) {
	/*
		Check that `a` is usable.
	*/
	if err = clear_if_uninitialized(a); err != nil { return 0, err; }
	/*
		Early out for single bit.
	*/
	if count == 1 {
		limb := offset / _DIGIT_BITS;
		if limb < 0 || limb >= a.used  { return 0, .Invalid_Argument; }
		i := _WORD(1 << _WORD((offset % _DIGIT_BITS)));
		return 1 if ((_WORD(a.digit[limb]) & i) != 0) else 0, nil;
	}

	if count > _WORD_BITS || count < 1 { return 0, .Invalid_Argument; }

	/*
		There are 3 possible cases.
		-	[offset:][:count] covers 1 DIGIT,
				e.g. offset:  0, count:  60 = bits 0..59
		-	[offset:][:count] covers 2 DIGITS,
				e.g. offset:  5, count:  60 = bits 5..59, 0..4
				e.g. offset:  0, count: 120 = bits 0..59, 60..119
		-	[offset:][:count] covers 3 DIGITS,
				e.g. offset: 40, count: 100 = bits 40..59, 0..59, 0..19
				e.g. offset: 40, count: 120 = bits 40..59, 0..59, 0..39
	*/

	limb        := offset / _DIGIT_BITS;
	bits_left   := count;
	bits_offset := offset % _DIGIT_BITS;

	num_bits    := min(bits_left, _DIGIT_BITS - bits_offset);

	shift       := offset % _DIGIT_BITS;
	mask        := (_WORD(1) << uint(num_bits)) - 1;
	res          = (_WORD(a.digit[limb]) >> uint(shift)) & mask;

	bits_left -= num_bits;
	if bits_left == 0 { return res, nil; }

	res_shift := num_bits;
	num_bits   = min(bits_left, _DIGIT_BITS);
	mask       = (1 << uint(num_bits)) - 1;

	res |= (_WORD(a.digit[limb + 1]) & mask) << uint(res_shift);

	bits_left -= num_bits;
	if bits_left == 0 { return res, nil; }

	mask     = (1 << uint(bits_left)) - 1;
	res_shift += _DIGIT_BITS;

	res |= (_WORD(a.digit[limb + 2]) & mask) << uint(res_shift);

	return res, nil;
}

/*
	Resize backing store.
*/
shrink :: proc(a: ^Int) -> (err: Error) {
	if a == nil {
		return .Invalid_Pointer;
	}

	needed := max(_MIN_DIGIT_COUNT, a.used);

	if a.used != needed {
		return grow(a, needed);
	}
	return nil;
}

int_grow :: proc(a: ^Int, digits: int, allow_shrink := false, allocator := context.allocator) -> (err: Error) {
	if a == nil {
		return .Invalid_Pointer;
	}
	raw := transmute(mem.Raw_Dynamic_Array)a.digit;

	/*
		We need at least _MIN_DIGIT_COUNT or a.used digits, whichever is bigger.
		The caller is asking for `digits`. Let's be accomodating.
	*/
	needed := max(_MIN_DIGIT_COUNT, a.used, digits);
	if !allow_shrink {
		needed = max(needed, raw.cap);
	}

	/*
		If not yet iniialized, initialize the `digit` backing with the allocator we were passed.
		Otherwise, `[dynamic]DIGIT` already knows what allocator was used for it, so resize will do the right thing.
	*/
	if raw.cap == 0 {
		a.digit = mem.make_dynamic_array_len_cap([dynamic]DIGIT, needed, needed, allocator);
	} else if raw.cap != needed {
		resize(&a.digit, needed);
	}
	/*
		Let's see if the allocation/resize worked as expected.
	*/
	if len(a.digit) != needed {
		return .Out_Of_Memory;
	}
	return nil;
}
grow :: proc { int_grow, };

/*
	Clear `Int` and resize it to the default size.
*/
int_clear :: proc(a: ^Int, minimize := false, allocator := context.allocator) -> (err: Error) {
	if a == nil {
		return .Invalid_Pointer;
	}

	raw := transmute(mem.Raw_Dynamic_Array)a.digit;
	if raw.cap != 0 {
		mem.zero_slice(a.digit[:a.used]);
	}
	a.sign = .Zero_or_Positive;
	a.used = 0;

	return grow(a, a.used, minimize, allocator);
}
clear :: proc { int_clear, };
zero  :: clear;

/*
	Set the `Int` to 1 and optionally shrink it to the minimum backing size.
*/
int_one :: proc(a: ^Int, minimize := false, allocator := context.allocator) -> (err: Error) {
	return copy(a, ONE, minimize, allocator);
}
one :: proc { int_one, };

/*
	Set the `Int` to -1 and optionally shrink it to the minimum backing size.
*/
int_minus_one :: proc(a: ^Int, minimize := false, allocator := context.allocator) -> (err: Error) {
	return set(a, -1, minimize, allocator);
}
minus_one :: proc { int_minus_one, };

/*
	Set the `Int` to Inf and optionally shrink it to the minimum backing size.
*/
int_inf :: proc(a: ^Int, minimize := false, allocator := context.allocator) -> (err: Error) {
	err = set(a, 1, minimize, allocator);
	a.flags |= { .Inf, };
	return err;
}
inf :: proc { int_inf, };

/*
	Set the `Int` to -Inf and optionally shrink it to the minimum backing size.
*/
int_minus_inf :: proc(a: ^Int, minimize := false, allocator := context.allocator) -> (err: Error) {
	err = set(a, -1, minimize, allocator);
	a.flags |= { .Inf, };
	return err;
}
minus_inf :: proc { int_inf, };

/*
	Set the `Int` to NaN and optionally shrink it to the minimum backing size.
*/
int_nan :: proc(a: ^Int, minimize := false, allocator := context.allocator) -> (err: Error) {
	err = set(a, 1, minimize, allocator);
	a.flags |= { .NaN, };
	return err;
}
nan :: proc { int_nan, };

power_of_two :: proc(a: ^Int, power: int) -> (err: Error) {
	/*
		Check that `a` is usable.
	*/
	if a == nil {
		return .Invalid_Pointer;
	}

	if power < 0 || power > _MAX_BIT_COUNT {
		return .Invalid_Argument;
	}

	/*
		Grow to accomodate the single bit.
	*/
	a.used = (power / _DIGIT_BITS) + 1;
	if err = grow(a, a.used); err != nil {
		return err;
	}
	/*
		Zero the entirety.
	*/
	mem.zero_slice(a.digit[:]);

	/*
		Set the bit.
	*/
	a.digit[power / _DIGIT_BITS] = 1 << uint((power % _DIGIT_BITS));
	return nil;
}

int_get_u128 :: proc(a: ^Int) -> (res: u128, err: Error) {
	return int_get(a, u128);
}
get_u128 :: proc { int_get_u128, };

int_get_i128 :: proc(a: ^Int) -> (res: i128, err: Error) {
	return int_get(a, i128);
}
get_i128 :: proc { int_get_i128, };

int_get_u64 :: proc(a: ^Int) -> (res: u64, err: Error) {
	return int_get(a, u64);
}
get_u64 :: proc { int_get_u64, };

int_get_i64 :: proc(a: ^Int) -> (res: i64, err: Error) {
	return int_get(a, i64);
}
get_i64 :: proc { int_get_i64, };

int_get_u32 :: proc(a: ^Int) -> (res: u32, err: Error) {
	return int_get(a, u32);
}
get_u32 :: proc { int_get_u32, };

int_get_i32 :: proc(a: ^Int) -> (res: i32, err: Error) {
	return int_get(a, i32);
}
get_i32 :: proc { int_get_i32, };

/*
	TODO: Think about using `count_bits` to check if the value could be returned completely,
	and maybe return max(T), .Integer_Overflow if not?
*/
int_get :: proc(a: ^Int, $T: typeid) -> (res: T, err: Error) where intrinsics.type_is_integer(T) {
	if err = clear_if_uninitialized(a); err != nil { return 0, err; }

	size_in_bits := int(size_of(T) * 8);
	i := int((size_in_bits + _DIGIT_BITS - 1) / _DIGIT_BITS);
	i  = min(int(a.used), i);

	for ; i >= 0; i -= 1 {
		res <<= uint(0) if size_in_bits <= _DIGIT_BITS else _DIGIT_BITS;
		res |= T(a.digit[i]);
		if size_in_bits <= _DIGIT_BITS {
			break;
		};
	}

	when !intrinsics.type_is_unsigned(T) {
		/*
			Mask off sign bit.
		*/
		res ~= 1 << uint(size_in_bits - 1);
		/*
			Set the sign.
		*/
		if a.sign == .Negative {
			res = -res;
		}
	}
	return;
}
get :: proc { int_get, };

int_get_float :: proc(a: ^Int) -> (res: f64, err: Error) {
	if err = clear_if_uninitialized(a); err != nil {
		return 0, err;
	}	

	l   := min(a.used, 17); // log2(max(f64)) is approximately 1020, or 17 legs.
	fac := f64(1 << _DIGIT_BITS);
	d   := 0.0;

	for i := l; i >= 0; i -= 1 {
		d = (d * fac) + f64(a.digit[i]);
	}

	res = -d if a.sign == .Negative else d;
	return;
}

/*
	Count bits in an `Int`.
*/
count_bits :: proc(a: ^Int) -> (count: int, err: Error) {
	if err = clear_if_uninitialized(a); err != nil {
		return 0, err;
	}
	/*
		Fast path for zero.
	*/
	if z, _ := is_zero(a); z {
		return 0, nil;
	}
	/*
		Get the number of DIGITs and use it.
	*/
	count  = (a.used - 1) * _DIGIT_BITS;
	/*
		Take the last DIGIT and count the bits in it.
	*/
	clz   := int(intrinsics.count_leading_zeros(a.digit[a.used - 1]));
	count += (_DIGIT_TYPE_BITS - clz);
	return;
}

/*
	Returns the number of trailing zeroes before the first one.
	Differs from regular `ctz` in that 0 returns 0.
*/
int_count_lsb :: proc(a: ^Int) -> (count: int, err: Error) {
	if err = clear_if_uninitialized(a); err != nil { return -1, err; }

	_ctz :: intrinsics.count_trailing_zeros;
	/*
		Easy out.
	*/
	if z, _ := is_zero(a); z { return 0, nil; }

	/*
		Scan lower digits until non-zero.
	*/
	x: int;
	for x = 0; x < a.used && a.digit[x] == 0; x += 1 {}

	q := a.digit[x];
	x *= _DIGIT_BITS;
	return x + count_lsb(q), nil;
}

platform_count_lsb :: #force_inline proc(a: $T) -> (count: int)
	where intrinsics.type_is_integer(T) && intrinsics.type_is_unsigned(T) {
	return int(intrinsics.count_trailing_zeros(a)) if a > 0 else 0;
}

count_lsb :: proc { int_count_lsb, platform_count_lsb, };

int_random_digit :: proc(r: ^rnd.Rand = nil) -> (res: DIGIT) {
	when _DIGIT_BITS == 60 { // DIGIT = u64
		return DIGIT(rnd.uint64(r)) & _MASK;
	} else when _DIGIT_BITS == 28 { // DIGIT = u32
		return DIGIT(rnd.uint32(r)) & _MASK;
	} else {
		panic("Unsupported DIGIT size.");
	}

	return 0; // We shouldn't get here.
}

int_rand :: proc(dest: ^Int, bits: int, r: ^rnd.Rand = nil) -> (err: Error) {
	bits := bits;

	if bits <= 0 { return .Invalid_Argument; }

	digits := bits / _DIGIT_BITS;
	bits   %= _DIGIT_BITS;

	if bits > 0 {
		digits += 1;
	}

	if err = grow(dest, digits); err != nil { return err; }

	for i := 0; i < digits; i += 1 {
		dest.digit[i] = int_random_digit(r) & _MASK;
	}
	if bits > 0 {
		dest.digit[digits - 1] &= ((1 << uint(bits)) - 1);
	}
	dest.used = digits;
	return nil;
}
rand :: proc { int_rand, };

/*
	Internal helpers.
*/
assert_initialized :: proc(a: ^Int, loc := #caller_location) {
	assert(is_initialized(a), "`Int` was not properly initialized.", loc);
}

zero_unused :: proc(dest: ^Int, old_used := -1) {
	if dest == nil { return; }
	if ! #force_inline is_initialized(dest) { return; }

	internal_zero_unused(dest, old_used);
}

clear_if_uninitialized_single :: proc(arg: ^Int) -> (err: Error) {
	if !is_initialized(arg) {
		if arg == nil { return nil; }
		return grow(arg, _DEFAULT_DIGIT_COUNT);
	}
	return err;
}

clear_if_uninitialized_multi :: proc(args: ..^Int) -> (err: Error) {
	for i in args {
		if i == nil { continue; }
		if !is_initialized(i) {
			e := grow(i, _DEFAULT_DIGIT_COUNT);
			if e != nil { err = e; }
		}
	}
	return err;
}
clear_if_uninitialized :: proc {clear_if_uninitialized_single, clear_if_uninitialized_multi, };

error_if_immutable_single :: proc(arg: ^Int) -> (err: Error) {
	if arg != nil && .Immutable in arg.flags { return .Assignment_To_Immutable; }
	return nil;
}

error_if_immutable_multi :: proc(args: ..^Int) -> (err: Error) {
	for i in args {
		if i != nil && .Immutable in i.flags { return .Assignment_To_Immutable; }
	}
	return nil;
}
error_if_immutable :: proc {error_if_immutable_single, error_if_immutable_multi, };

/*
	Allocates several `Int`s at once.
*/
int_init_multi :: proc(integers: ..^Int) -> (err: Error) {
	integers := integers;
	for a in &integers {
		if err = clear(a); err != nil { return err; }
	}
	return nil;
}

init_multi :: proc { int_init_multi, };

_copy_digits :: proc(dest, src: ^Int, digits: int) -> (err: Error) {
	digits := digits;
	if err = clear_if_uninitialized(src);  err != nil { return err; }
	if err = clear_if_uninitialized(dest); err != nil { return err; }
	/*
		If dest == src, do nothing
	*/
	if (dest == src) {
		return nil;
	}

	digits = min(digits, len(src.digit), len(dest.digit));
	mem.copy_non_overlapping(&dest.digit[0], &src.digit[0], size_of(DIGIT) * digits);
	return nil;
}

/*
	Trim unused digits.

	This is used to ensure that leading zero digits are trimmed and the leading "used" digit will be non-zero.
	Typically very fast.  Also fixes the sign if there are no more leading digits.
*/
clamp :: proc(a: ^Int) -> (err: Error) {
	if err = clear_if_uninitialized(a); err != nil {
		return err;
	}
	for a.used > 0 && a.digit[a.used - 1] == 0 {
		a.used -= 1;
	}

	if z, _ := is_zero(a); z {
		a.sign = .Zero_or_Positive;
	}
	return nil;
}


/*
	Initialize constants.
*/
ONE, ZERO, MINUS_ONE, INF, MINUS_INF, NAN := &Int{}, &Int{}, &Int{}, &Int{}, &Int{}, &Int{};

initialize_constants :: proc() -> (res: int) {
	set(     ZERO,  0);      ZERO.flags = {.Immutable};
	set(      ONE,  1);       ONE.flags = {.Immutable};
	set(MINUS_ONE, -1); MINUS_ONE.flags = {.Immutable};

	/*
		We set these special values to -1 or 1 so they don't get mistake for zero accidentally.
		This allows for shortcut tests of is_zero as .used == 0.
	*/
	set(      NAN,  1);       NAN.flags = {.Immutable, .NaN};
	set(      INF,  1);       INF.flags = {.Immutable, .Inf};
	set(      INF, -1); MINUS_INF.flags = {.Immutable, .Inf};

	return _DEFAULT_MUL_KARATSUBA_CUTOFF;
}

destroy_constants :: proc() {
	destroy(ONE, ZERO, MINUS_ONE, INF, NAN);
}

