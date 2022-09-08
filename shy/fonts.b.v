// Copyright(C) 2022 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
//
//
module shy

import os
import fontstash
import sokol.sfons
import sokol.sgl

struct Fonts {
	ShyStruct
mut:
	ready     bool
	contexts  []&FontContext
	font_data map[string][]u8
}

struct FontsConfig {
	ShyStruct
	prealloc_contexts u16 = defaults.fonts.preallocate // > ~8 needs sokol.gfx.Desc.pipeline_pool_size / .context_pool_size
	preload           map[string]string // preload[font_name] = path_to_font
}

[heap]
struct FontContext {
mut:
	in_use bool
	fsc    &fontstash.Context
	sgl    sgl.Context
	fonts  map[string]int
}

fn (mut fs Fonts) load_font(name string, path string) ! {
	fs.shy.vet_issue(.warn, .hot_code, @STRUCT + '.' + @FN, 'memory fragmentation can happen when allocating in hot code paths. It is, in general, better to pre-load your assets...')

	if bytes := os.read_bytes(path) {
		fs.font_data[name] = bytes
		fs.shy.log.ginfo(@STRUCT + '.' + @FN, 'loaded $name: "$path"')
	} else {
		return error('${@STRUCT}.${@FN}' + ': could not load $name "$path"')
	}
}

fn (mut fs Fonts) init(config FontsConfig) ! {
	fs.shy = config.shy
	mut s := fs.shy
	s.log.gdebug(@STRUCT + '.' + @FN, 'hi')

	// Load the Shy default font
	mut default_font := $embed_file('fonts/Allerta/Allerta-Regular.ttf')
	fs.font_data[defaults.font.name] = default_font.to_bytes()
	fs.shy.log.ginfo(@STRUCT, 'loaded default: "$default_font.path"')

	for font_name, font_path in config.preload {
		fs.load_font(font_name, font_path) or {
			s.log.gerror(@STRUCT, ' pre-loading failed: $err.msg()')
		}
	}

	s.log.gdebug(@STRUCT, 'pre-allocating $config.prealloc_contexts contexts...')
	$if shy_vet ? {
		if config.prealloc_contexts > defaults.fonts.preallocate {
			s.vet_issue(.warn, .misc, @STRUCT + '.' + @FN, ' keep in mind that pre-allocating many font contexts is quite memory consuming')
		}
	}

	sample_count := fs.shy.config.render.msaa
	sgl_context_desc := sgl.ContextDesc{
		sample_count: sample_count
	} // TODO apply values for max_vertices etc.

	for _ in 0 .. config.prealloc_contexts {
		fons_context := sfons.create(1024, 1024, 1)
		sgl_context := sgl.make_context(&sgl_context_desc)
		// Default context
		mut context := &FontContext{
			fsc: fons_context
			sgl: sgl_context
		}

		for font_name, _ in config.preload {
			if bytes := fs.font_data[font_name] {
				context.fonts[font_name] = fons_context.add_font_mem(font_name, bytes,
					false)
			}
		}
		s.log.gdebug(@STRUCT + '.' + @FN, 'adding font context ${ptr_str(context.fsc)}...')
		fs.contexts << context
	}
	fs.ready = true
}

fn (mut fs Fonts) shutdown() ! {
	fs.shy.log.gdebug(@STRUCT + '.' + @FN, 'bye')
	mut s := fs.shy
	for context in fs.contexts {
		if !isnil(context.fsc) {
			s.log.gdebug(@STRUCT + '.' + @FN, 'destroying font context ${ptr_str(context.fsc)}...')
			sfons.destroy(context.fsc)
			unsafe {
				context.fsc = nil
			}
		}
	}
	for font_name, data in fs.font_data {
		if data.len > 0 {
			s.log.gdebug(@STRUCT + '.' + @FN, 'freeing font $font_name data...')
			unsafe { data.free() }
		}
	}
}

fn (mut fs Fonts) get_context() &FontContext {
	for fc in fs.contexts {
		if !fc.in_use {
			unsafe {
				fc.in_use = true
			}
			return fc
		}
	}
	assert false, '${@STRUCT}.${@FN}' + ': no available font contexts'
	fs.shy.log.gcritical(@STRUCT + '.' + @FN, 'no available font contexts, expect crash and burn...')
	return &FontContext{
		fsc: unsafe { nil }
	} // NOTE dummy return to please the V compiler...
}

fn (mut fs Fonts) on_frame_end() {
	for mut fc in fs.contexts {
		if fc.in_use {
			fc.in_use = false
			// FLOOD fs.shy.log.gdebug(@STRUCT + '.' + @FN, 'handing out ${ptr_str(fc.fsc)}...')
		}
	}
}

fn (fc &FontContext) set_defaults() {
	font_context := fc.fsc

	font_id := fc.fonts[defaults.font.name]

	white := sfons.rgba(255, 255, 255, 255)

	font_context.set_font(font_id)
	font_context.set_color(white)
	font_context.set_size(defaults.font.size)
}

fn (fc &FontContext) begin() {
	fc.fsc.clear_state()
	fc.set_defaults()
}

fn (fc &FontContext) end() {
	sfons.flush(fc.fsc)
	sgl.draw()
	// TODO needs patching of sokol_gfx.h for more text drawing contexts to co-exist in same frame :(
	// See https://github.com/floooh/sokol/issues/703 foor your own issue report and solution
}