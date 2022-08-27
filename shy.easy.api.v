// Copyright(C) 2022 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
//
// This file defines (most of) Shy's public API
module shy

// import shy.vec
// High-level API

pub struct Easy {
	ShyStruct
mut:
	audio_engine &AudioEngine = shy.null
}

pub fn (mut e Easy) init() ! {
	e.audio_engine = e.shy.api.audio.engine(0)!
}

[params]
pub struct EasyText {
	x      f32
	y      f32
	text   string
	anchor Anchor
}

[inline]
pub fn (e Easy) text(et EasyText) {
	gfx := e.shy.api.gfx

	mut dt := gfx.draw.new_text()
	dt.begin()
	mut t := dt.new()
	t.text = et.text
	t.x = et.x
	t.y = et.y
	t.draw()
	dt.end()
}

// Shape drawing sub-system

[params]
pub struct EasyRect {
	Rect
}

[inline]
pub fn (e Easy) rect(er EasyRect) {
	gfx := e.shy.api.gfx
	mut d := gfx.draw.new_2d()
	d.begin()
	mut r := d.new_rect()
	r.x = er.x
	r.y = er.y
	r.w = er.w
	r.h = er.h
	r.draw()
	d.end()
}

// Audio sub-system

[params]
pub struct EasySound {
	ShyStruct
	engine &AudioEngine
	id     u16
	id_end u16
pub mut:
	loop bool
}

[params]
pub struct EasySoundConfig {
	path      string
	loop      bool
	instances u8 // number of copies of the sound, needed to support repeated playback of the same sound
}

pub fn (e Easy) new_sound(esc EasySoundConfig) !&EasySound {
	e.shy.vet_issue(.warn, .hot_code, @STRUCT + '.' + @FN +
		'memory fragmentation can happen when allocating in hot code paths. It is, in general, better to pre-load your assets...')
	mut audio := e.audio_engine

	mut id := u16(0)
	mut id_end := u16(0)
	if esc.instances > 1 {
		id, id_end = audio.load_instanced(esc.path, esc.instances)!
	} else {
		id = audio.load(esc.path)!
	}
	return &EasySound{
		shy: e.shy
		engine: e.audio_engine
		id: id
		id_end: id_end
		loop: esc.loop
	}
}

pub fn (es &EasySound) play() {
	es.engine.set_looping(es.id, es.loop)
	mut id := es.id
	if es.id_end > 0 {
		for i in id .. es.id_end {
			if !es.engine.is_playing(i) {
				id = i
				break
			}
		}
	}
	es.engine.play(id)
}

pub fn (es &EasySound) is_looping() bool {
	mut id := es.id
	if es.id_end > 0 {
		for i in id .. es.id_end {
			if es.engine.is_looping(i) {
				return true
			}
		}
	}
	return es.engine.is_looping(id)
}

pub fn (es &EasySound) is_playing() bool {
	mut id := es.id
	if es.id_end > 0 {
		for i in id .. es.id_end {
			if es.engine.is_playing(i) {
				return true
			}
		}
	}
	return es.engine.is_playing(id)
}

pub fn (es &EasySound) stop() {
	es.engine.stop(es.id)
	es.engine.set_looping(es.id, es.loop)
}
