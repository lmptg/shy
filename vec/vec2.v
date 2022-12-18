// Copyright(C) 2020-2022 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license file distributed with this software package

module vec

import math

pub struct Vec2[T] {
pub mut:
	x T
	y T
}

pub fn vec2[T](x T, y T) Vec2[T] {
	return Vec2[T]{
		x: x
		y: y
	}
}

pub fn (mut v Vec2[T]) zero() {
	v.x = 0
	v.y = 0
}

pub fn (mut v Vec2[T]) one() {
	v.x = 1
	v.y = 1
}

pub fn (v Vec2[T]) copy() Vec2[T] {
	return Vec2[T]{v.x, v.y}
}

pub fn (mut v Vec2[T]) from(u Vec2[T]) {
	v.x = u.x
	v.y = u.y
}

//
// Addition
//
// + operator overload. Adds two vectors
pub fn (v1 Vec2[T]) + (v2 Vec2[T]) Vec2[T] {
	return Vec2[T]{v1.x + v2.x, v1.y + v2.y}
}

pub fn (v Vec2[T]) add(u Vec2[T]) Vec2[T] {
	return v + u
}

pub fn (v Vec2[T]) add_scalar[U](scalar U) Vec2[T] {
	return Vec2[T]{v.x + T(scalar), v.y + T(scalar)}
}

pub fn (mut v Vec2[T]) plus(u Vec2[T]) {
	v.x += u.x
	v.y += u.y
}

pub fn (mut v Vec2[T]) plus_scalar[U](scalar U) {
	v.x += T(scalar)
	v.y += T(scalar)
}

//
// Subtraction
//
pub fn (v Vec2[T]) - (u Vec2[T]) Vec2[T] {
	return Vec2[T]{v.x - u.x, v.y - u.y}
}

pub fn (v Vec2[T]) sub(u Vec2[T]) Vec2[T] {
	return v - u
}

pub fn (v Vec2[T]) sub_scalar[U](scalar U) Vec2[T] {
	return Vec2[T]{v.x - T(scalar), v.y - T(scalar)}
}

pub fn (mut v Vec2[T]) subtract(u Vec2[T]) {
	v.x -= u.x
	v.y -= u.y
}

pub fn (mut v Vec2[T]) subtract_scalar[U](scalar U) {
	v.x -= T(scalar)
	v.y -= T(scalar)
}

//
// Multiplication
//
pub fn (v1 Vec2[T]) * (v2 Vec2[T]) Vec2[T] {
	return Vec2[T]{v1.x * v2.x, v1.y * v2.y}
}

pub fn (v Vec2[T]) mul(u Vec2[T]) Vec2[T] {
	return v * u
}

pub fn (v Vec2[T]) mul_scalar[U](scalar U) Vec2[T] {
	return Vec2[T]{v.x * T(scalar), v.y * T(scalar)}
}

pub fn (mut v Vec2[T]) multiply(u Vec2[T]) {
	v.x *= u.x
	v.y *= u.y
}

pub fn (mut v Vec2[T]) multiply_scalar[U](scalar U) {
	v.x *= T(scalar)
	v.y *= T(scalar)
}

//
// Division
//
pub fn (v1 Vec2[T]) / (v2 Vec2[T]) Vec2[T] {
	return Vec2[T]{v1.x / v2.x, v1.y / v2.y}
}

pub fn (v Vec2[T]) div(u Vec2[T]) Vec2[T] {
	return v / u
}

pub fn (v Vec2[T]) div_scalar[U](scalar U) Vec2[T] {
	return Vec2[T]{v.x / T(scalar), v.y / T(scalar)}
}

pub fn (mut v Vec2[T]) divide(u Vec2[T]) {
	v.x /= u.x
	v.y /= u.y
}

pub fn (mut v Vec2[T]) divide_scalar[U](scalar U) {
	v.x /= T(scalar)
	v.y /= T(scalar)
}

//
// Utility
//
pub fn (v Vec2[T]) length() T {
	if v.x == 0 && v.y == 0 {
		return 0
	}
	$if T is f64 {
		return math.sqrt((v.x * v.x) + (v.y * v.y))
	} $else $if T is f32 {
		return math.sqrtf((v.x * v.x) + (v.y * v.y))
	} $else {
		return T(math.sqrt(f64(v.x * v.x) + f64(v.y * v.y)))
	}
	panic('TODO ${@FN} not implemented for type')
	return T(0.0)
	// $compile_error('Type T in Vec2<T>.length() is not supported')
}

pub fn (v Vec2[T]) dot(u Vec2[T]) T {
	return (v.x * u.x) + (v.y * u.y)
}

// cross returns the cross product of v and u
pub fn (v Vec2[T]) cross(u Vec2[T]) T {
	return (v.x * u.y) - (v.y * u.x)
}

// unit return this vector's unit vector
pub fn (v Vec2[T]) unit() Vec2[T] {
	length := v.length()
	return Vec2[T]{v.x / length, v.y / length}
}

pub fn (v Vec2[T]) perp() Vec2[T] {
	return Vec2[T]{-v.y, v.x}
}

// perpendicular return the perpendicular vector of this
pub fn (v Vec2[T]) perpendicular(u Vec2[T]) Vec2[T] {
	return v - v.project(u)
}

// project returns the projected vector
pub fn (v Vec2[T]) project(u Vec2[T]) Vec2[T] {
	percent := v.dot(u) / u.dot(v)
	return u.mul_scalar(percent)
}

// eq returns a bool indicating if the two vectors are equal
pub fn (v Vec2[T]) eq(u Vec2[T]) bool {
	return v.x == u.x && v.y == u.y
}

/*
// eq_epsilon returns a bool indicating if the two vectors are equal within epsilon
[markused]
pub fn (v Vec2<T>) eq_epsilon(u Vec2<T>) bool {
	return v.x.eq_epsilon(u.x) && v.y.eq_epsilon(u.y)
}*/

// eq_approx will return a bool indicating if vectors are approximately equal within the tolerance
pub fn (v Vec2[T]) eq_approx(u Vec2[T], tolerance T) bool {
	diff_x := math.abs(v.x - u.x)
	diff_y := math.abs(v.y - u.y)
	if diff_x <= tolerance && diff_y <= tolerance {
		return true
	}

	max_x := math.max(math.abs(v.x), math.abs(u.x))
	max_y := math.max(math.abs(v.y), math.abs(u.y))
	if diff_x < max_x * tolerance && diff_y < max_y * tolerance {
		return true
	}

	return false
}

// is_approx_zero will return a bool indicating if this vector is zero within tolerance
pub fn (v Vec2[T]) is_approx_zero(tolerance T) bool {
	if math.abs(v.x) <= tolerance && math.abs(v.y) <= tolerance {
		return true
	}
	return false
}

// eq_f64 returns a bool indicating if the x and y both equals the scalar
pub fn (v Vec2[T]) eq_scalar[U](scalar U) bool {
	return v.x == T(scalar) && v.y == scalar
}

// distance returns the distance between the two vectors
pub fn (v Vec2[T]) distance(u Vec2[T]) T {
	$if T is f64 {
		return math.sqrt((v.x - u.x) * (v.x - u.x) + (v.y - u.y) * (v.y - u.y))
	} $else $if T is f32 {
		return math.sqrtf((v.x - u.x) * (v.x - u.x) + (v.y - u.y) * (v.y - u.y))
	} $else {
		return T(math.sqrt(f64(v.x - u.x) * f64(v.x - u.x) + f64(v.y - u.y) * f64(v.y - u.y)))
	}
	panic('TODO ${@FN} not implemented for type')
	return T(0.0)
	// $compile_error('Type T in Vec2<T>.length() is not supported')
}

// manhattan_distance returns the Manhattan Distance between the two vectors
pub fn (v Vec2[T]) manhattan_distance(u Vec2[T]) T {
	return math.abs(v.x - u.x) + math.abs(v.y - u.y)
}

// angle_between returns the angle in radians between the two vectors
pub fn (v Vec2[T]) angle_between(u Vec2[T]) T {
	$if T is f64 {
		return math.atan2((v.y - u.y), (v.x - u.x))
	} $else $if T is f32 {
		return f32(math.atan2((v.y - u.y), (v.x - u.x)))
	} $else {
		return T(math.atan2(f64(v.y - u.y), f64(v.x - u.x)))
	}

	panic('TODO ${@FN} not implemented for type')
	return T(0.0)
	// $compile_error('Type T in Vec2<T>.length() is not supported')
}

// angle returns the angle in radians of the vector
pub fn (v Vec2[T]) angle() T {
	$if T is f64 {
		return math.atan2(v.y, v.x)
	} $else $if T is f32 {
		return f32(math.atan2(v.y, v.x))
	} $else {
		return T(math.atan2(f64(v.y), f64(v.x)))
	}

	panic('TODO ${@FN} not implemented for type')
	return T(0.0)
	// $compile_error('Type T in Vec2<T>.length() is not supported')
}

// abs will set x and y values to their absolute values
pub fn (mut v Vec2[T]) abs() {
	if v.x < 0 {
		v.x = math.abs(v.x)
	}
	if v.y < 0 {
		v.y = math.abs(v.y)
	}
}

// clean sets all components to zero (0) if they fall within `tolerance`.
pub fn (v Vec2[T]) clean(tolerance f64) Vec2[T] {
	mut r := v.copy()
	if math.abs(v.x) < tolerance {
		r.x = 0
	}
	if math.abs(v.y) < tolerance {
		r.y = 0
	}
	return r
}

// inv returns the reciprocal of the vector
pub fn (v Vec2[T]) inv() Vec2[T] {
	return Vec2[T]{
		x: if v.x != 0 { T(1) / v.x } else { 0 }
		y: if v.y != 0 { T(1) / v.y } else { 0 }
	}
}

// mod returns module of the vector xy
pub fn (v Vec2[T]) mod() T {
	return T(math.sqrt(v.x * v.x + v.y * v.y))
}

// mod_x returns module for 1d vector x, y ignored
pub fn (v Vec2[T]) mod_x() T {
	return T(math.sqrt(v.x * v.x))
}

// mod_y returns module for 1d vector y, x ignored
pub fn (v Vec2[T]) mod_y() T {
	return T(math.sqrt(v.y * v.y))
}

// normalize normalizes the vector
pub fn (v Vec2[T]) normalize() Vec2[T] {
	m := v.mod()
	if m == 0 {
		return vec2[T](0, 0)
	}
	return Vec2[T]{
		x: v.x * (1 / m)
		y: v.y * (1 / m)
	}
}

// normalize_x normalizes only the x component, y is set to 0
pub fn (v Vec2[T]) normalize_x() Vec2[T] {
	m := v.mod_x()
	if m == 0 {
		return vec2[T](0, 0)
	}
	return Vec2[T]{
		x: v.x * (1 / m)
		y: 0
	}
}

// normalize_y normalizes only the y component, x is set to 0
pub fn (v Vec2[T]) normalize_y() Vec2[T] {
	m := v.mod_y()
	if m == 0 {
		return vec2[T](0, 0)
	}
	return Vec2[T]{
		x: 0
		y: v.y * (1 / m)
	}
}

// sum returns a sum of all the elements
pub fn (v Vec2[T]) sum() T {
	return v.x + v.y
}
