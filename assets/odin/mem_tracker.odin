/*

1. Copy and paste the ff at the start of your main proc:
```
when ODIN_DEBUG {
	context.allocator, context.temp_allocator = record_leaks()
	defer display_leaks()
}
```

2. Run:
```
odin run . --debug
```

*/
package main

import "core:fmt"
import "core:mem"

_ :: fmt
_ :: mem

when ODIN_DEBUG {
	main_tracker: mem.Tracking_Allocator
	temp_tracker: mem.Tracking_Allocator

	record_leaks :: proc() -> (main_allocator: mem.Allocator, temp_allocator: mem.Allocator) {
		mem.tracking_allocator_init(&main_tracker, context.allocator)
		mem.tracking_allocator_init(&temp_tracker, context.temp_allocator)
		return mem.tracking_allocator(&main_tracker), mem.tracking_allocator(&temp_tracker)
	}

	display_leaks :: proc() {
		fmt.println("\n================= MEMORY TRACKER =================")
		leaks := 0
		for _, entry in main_tracker.allocation_map {
			fmt.printfln("MAIN LEAK: %v BYTES @ %v", entry.size, entry.location)
			leaks += entry.size
		}
		for _, entry in temp_tracker.allocation_map {
			fmt.printfln("TEMP LEAK: %v BYTES @ %v", entry.size, entry.location)
			leaks += entry.size
		}
		bad_frees := 0
		for entry in main_tracker.bad_free_array {
			fmt.printfln("MAIN BAD FREE: %v @ %v", entry.memory, entry.location)
			bad_frees += 1
		}
		for entry in temp_tracker.bad_free_array {
			fmt.printfln("TEMP BAD FREE: %v @ %v", entry.memory, entry.location)
			bad_frees += 1
		}
		fmt.println("==================================================")
		fmt.printfln("TOTAL LEAKS: %.2f KB | TOTAL BAD FREES: %v", f64(leaks) / 1024, bad_frees)
		fmt.println("==================================================\n")

		mem.tracking_allocator_destroy(&main_tracker)
		mem.tracking_allocator_destroy(&temp_tracker)
	}
}

