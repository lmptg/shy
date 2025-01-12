// Copyright(C) 2022 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module ui

import shy.lib as shy

// Item is the base type for all UI elements.
// By embedding `Item` in a struct - the struct fulfills
// the `Node` interface required for a type to be an UI item.
// Likewise any new types embedding `Item` thus also fulfill
// the `Node` interface requirements - making them "automagically"
// compliant with the scene graph - and allows for easy, user-land,
// creation of new UI nodes that can be reused across code-bases.
[heap]
pub struct Item {
	shy.Rect
pub:
	id u64
mut:
	// NOTE The `unsafe { nil }` assignment once resulted in several V bugs: https://github.com/vlang/v/issues/16882
	// ... which was quickly fixed but one of them couldn't be made as an MRE (minimal reproducible example) - so it's
	// a target of regression: https://github.com/vlang/v/commit/2119a24 <- this commit has the fix.
	parent   &Node = unsafe { nil }
	body     []&Node
	on_event []OnEventFn
}

// parent returns this `Item`'s parent.
pub fn (i &Item) parent() &Node {
	assert i != unsafe { nil }
	// TODO returning ?&Node is not possible currently: if isnil(i.parent) { return none }
	return i.parent
}

// draw draws the `Item` and/or any child nodes.
pub fn (i &Item) draw(ui &UI) {
	for child in i.body {
		child.draw(ui)
	}
}

// event sends an `Event` any child nodes and/or it's own listeners.
pub fn (i &Item) event(e Event) ?&Node {
	// By sending the event on to the children nodes
	// it's effectively *bubbling* the event upwards in the
	// tree / scene graph
	for child in i.body {
		if node := child.event(e) {
			return node
		}
	}
	for on_event in i.on_event {
		assert !isnil(on_event)
		if on_event(i, e) {
			// If `on_event` returns true, it means
			// a listener on *this* item has accepted the event
			return i
		}
	}
	return none
}

/*
fn (mut i Item) free() {
	for child in i.body {
		child.free()
		unsafe { free(child) }
	}
	i.body.clear()
	i.body.free()
}*/

[heap]
pub struct Rectangle {
	Item
}

// parent returns the parent Node.
pub fn (r &Rectangle) parent() &Node {
	return r.Item.parent()
}

// draw draws the `Item` and/or any child nodes.
pub fn (r &Rectangle) draw(ui &UI) {
	// println('${@STRUCT}.${@FN} ${ptr_str(r)}')
	// println('${@STRUCT}.${@FN} ${r}')
	er := ui.easy.rect(
		x: r.x
		y: r.y
		width: r.width
		height: r.height
	)
	er.draw()

	r.Item.draw(ui)
}

// event sends an `Event` any child nodes and/or it's own listeners.
pub fn (r &Rectangle) event(e Event) ?&Node {
	return r.Item.event(e)
}

[heap]
pub struct EventArea {
	Item
}

// parent returns the parent Node.
pub fn (ea &EventArea) parent() &Node {
	return ea.Item.parent()
}

// draw draws the `Item` and/or any child nodes.
pub fn (ea &EventArea) draw(ui &UI) {
	ea.Item.draw(ui)
}

// event sends an `Event` any child nodes and/or it's own listeners.
pub fn (ea &EventArea) event(e Event) ?&Node {
	return ea.Item.event(e)
}

[heap]
pub struct PointerEventArea {
	EventArea
	on_pointer_event []OnPointerEventFn
}

// parent returns the parent Node.
pub fn (pea &PointerEventArea) parent() &Node {
	return pea.EventArea.parent()
}

// draw draws the `Item` and/or any child nodes.
pub fn (pea &PointerEventArea) draw(ui &UI) {
	pea.EventArea.draw(ui)
}

// event sends an `Event` any child nodes and/or it's own listeners.
pub fn (pea &PointerEventArea) event(e Event) ?&Node {
	if e is MouseButtonEvent || e is MouseMotionEvent || e is MouseWheelEvent {
		ex := match e {
			MouseButtonEvent, MouseMotionEvent, MouseWheelEvent {
				e.x
			}
			else {
				0
			}
		}
		ey := match e {
			MouseButtonEvent, MouseMotionEvent, MouseWheelEvent {
				e.y
			}
			else {
				0
			}
		}
		for on_pointer_event in pea.on_pointer_event {
			assert !isnil(on_pointer_event)
			mut pe := PointerEvent{
				event: e
				x: ex
				y: ey
			}

			// TODO BUG pea pointer address is not the same in userspace callbacks?!
			/*
			eprintln('${@STRUCT}.${@FN} ea: ${ptr_str(pea.EventArea)}')
			eprintln('${@STRUCT}.${@FN} ea.this: ${ptr_str(pea.EventArea.this)}')
			eprintln('${@STRUCT}.${@FN} pea: ${ptr_str(pea)}')
			eprintln('${@STRUCT}.${@FN} id: ${pea.id}')
			eprintln('${@STRUCT}.${@FN} this: ${ptr_str(pea.this)}')

			//unsafe { pea.this = pea }
			//if on_pointer_event(pea.EventArea, pe) {
			mut copy := &PointerEventArea{...pea}
			unsafe { copy.this = copy }
			eprintln('${@STRUCT}.${@FN} copy ea: ${ptr_str(copy.EventArea)}')
			eprintln('${@STRUCT}.${@FN} copy ea.this: ${ptr_str(copy.EventArea.this)}')
			eprintln('${@STRUCT}.${@FN} copy pea: ${ptr_str(copy)}')
			eprintln('${@STRUCT}.${@FN} copy id: ${copy.id}')
			eprintln('${@STRUCT}.${@FN} copy this: ${ptr_str(copy.this)}')
			*/

			if on_pointer_event(pea, pe) {
				// If `on_pointer_event` returns true, it means
				// a listener on *this* item has accepted the event
				return pea
			}
		}
	}
	return pea.EventArea.event(e)
}
