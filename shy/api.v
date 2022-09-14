// Copyright(C) 2022 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module shy

struct API {
	ShyStruct
mut:
	wm     &WM
	gfx    &GFX
	assets &Assets
	audio  &Audio
	input  &Input
	system &System
}

pub fn (mut a API) init(shy_instance &Shy) ! {
	mut s := unsafe { shy_instance }
	a.shy = s
	s.log.gdebug('${@STRUCT}.${@FN}', 'hi')
	boot := Boot{
		shy: s
	}
	a.wm = boot.init()!

	a.system = &System{
		shy: s
	}
	a.system.init()!

	a.assets = &Assets{
		shy: s
	}
	a.assets.init()!

	a.gfx = &GFX{
		shy: s
	}
	a.gfx.init()!

	a.wm.init()!

	// a.gfx.init_subsystems()!

	a.audio = &Audio{
		shy: s
	}
	a.audio.init()!

	a.input = &Input{
		shy: s
	}
	a.input.init()!
}

pub fn (mut a API) shutdown() ! {
	a.shy.log.gdebug('${@STRUCT}.${@FN}', 'bye')

	a.input.shutdown()!
	a.assets.shutdown()!
	a.audio.shutdown()!
	a.system.shutdown()!
	a.wm.shutdown()!
	a.gfx.shutdown()!
	unsafe { a.free() }
}

[unsafe]
fn (mut a API) free() {
	a.shy.log.gdebug('${@STRUCT}.${@FN}', '')
	unsafe {
		free(a.input)
		free(a.assets)
		free(a.gfx)
		free(a.audio)
		free(a.system)
		free(a.wm)
	}
}

pub fn (a &API) wm() &WM {
	return a.wm
}

pub fn (a &API) gfx() &GFX {
	return a.gfx
}

pub fn (a &API) assets() &Assets {
	return a.assets
}

pub fn (a &API) audio() &Audio {
	return a.audio
}

pub fn (a &API) input() &Input {
	return a.input
}

pub fn (a &API) system() &System {
	return a.system
}