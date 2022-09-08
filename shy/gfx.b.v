// Copyright(C) 2022 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module shy

import sokol.gfx
import sokol.sgl
import sgp

pub struct GFX {
	ShyStruct
mut:
	draw &Draw = null
	// sokol
	pass_action gfx.PassAction
}

pub fn (mut g GFX) init() ! {
	mut s := g.shy
	s.log.gdebug(@STRUCT + '.' + @FN, 'hi')
	mut gfx_desc := gfx.Desc{
		shader_pool_size: 4 * 512 // default 32, NOTE this number affects the prealloc_contexts in fonts.b.v...
		context_pool_size: 4 * 512 // default 4, NOTE this number affects the prealloc_contexts in fonts.b.v...
		pipeline_pool_size: 4 * 1024 // default 64, NOTE this number affects the prealloc_contexts in fonts.b.v...
	}
	gfx_desc.context.sample_count = s.config.render.msaa
	gfx.setup(&gfx_desc)
	assert gfx.is_valid()

	// Create a black color as a default pass (default window background color)
	color := s.config.window.color.as_f32()
	pass_action := gfx.create_clear_pass(color.r, color.g, color.b, color.a)
	g.pass_action = pass_action

	// sokol_gl is used by the font and image system
	sample_count := s.config.render.msaa
	sgl_desc := &sgl.Desc{
		context_pool_size: 2 * 512 // TODO default 4, NOTE this number affects the prealloc_contexts in fonts.b.v...
		pipeline_pool_size: 2 * 1024 // TODO default 4, NOTE this number affects the prealloc_contexts in fonts.b.v...
		sample_count: sample_count
	}
	sgl.setup(sgl_desc)

	// Initialize Sokol GP which is used for shape drawing.
	// TODO Adjust the size of command buffers.
	sgp_desc := sgp.Desc{
		// max_vertices: 1_000_000
		// max_commands: 100_000
	}
	sgp.setup(&sgp_desc)
	if !sgp.is_valid() {
		error_msg := unsafe { cstring_to_vstring(sgp.get_error_message(sgp.get_last_error())) }
		panic('Failed to create Sokol GP context:\n$error_msg')
	}

	g.draw = &Draw{
		shy: s
	}
}

pub fn (mut g GFX) shutdown() ! {
	sgp.shutdown()

	gfx.shutdown()
}

pub fn (mut g GFX) begin() {
	s := g.shy
	mut win := s.active_window()
	// TODO multi window support
	w, h := win.drawable_size()
	gfx.begin_default_pass(&g.pass_action, w, h)
}

pub fn (g GFX) commit() {
	gfx.commit()
}

pub fn (g GFX) end() {
	gfx.end_pass()
}

pub fn (g GFX) swap() {
	mut win := g.shy.active_window()
	win.swap()
}