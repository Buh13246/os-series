
kernel_source_files := $(shell find src/impl/kernel -name *.c)
kernel_object_files := $(patsubst src/impl/kernel/%.c, build/kernel/%.o, $(kernel_source_files))

x86_64_asm_source_files := $(shell find src/impl/x86_64 -name *.asm)
x86_64_asm_object_files := $(patsubst src/impl/x86_64/%.asm, build/x86_64/%.o, $(x86_64_asm_source_files))

x86_64_c_source_files := $(shell find src/impl/x86_64 -name *.c)
x86_64_c_object_files := $(patsubst src/impl/x86_64/%.c, build/x86_64/%.o, $(x86_64_c_source_files))

x86_64_object_files := $(x86_64_asm_object_files) $(x86_64_c_object_files)

arm_asm_source_files := $(shell find src/impl/arm -name *.S)
arm_asm_object_files := $(patsubst src/impl/arm/%.S, build/arm/%.o, $(arm_asm_source_files))

arm_c_source_files := $(shell find src/impl/arm -name *.c)
arm_c_object_files := $(patsubst src/impl/arm/%.c, build/arm/%.o, $(arm_c_source_files))

arm_object_files := $(arm_asm_object_files) $(arm_c_object_files)

.PHONY: clean_kernel
clean_kernel:
	rm -f build/kernel/*.o || true

$(kernel_object_files): build/kernel/%.o : src/impl/kernel/%.c
	mkdir -p $(dir $@) && \
	test "$(ARCH)" = "x86_64" && x86_64-elf-gcc -c -I src/interfaces -I src/impl/x86_64/ -ffreestanding $(patsubst build/kernel/%.o, src/impl/kernel/%.c, $@) -o $@ || \
	(test "$(ARCH)" = "arm" && arm-none-eabi-gcc -mcpu=cortex-a7 -fpic -ffreestanding -std=gnu99 -Wall -Wextra -I src/interfaces -I src/impl/arm/ -c $(patsubst build/kernel/%.o, src/impl/kernel/%.c, $@) -o $@)

$(x86_64_asm_object_files): build/x86_64/%.o : src/impl/x86_64/%.asm
	mkdir -p $(dir $@) && \
	nasm -f elf64 $(patsubst build/x86_64/%.o, src/impl/x86_64/%.asm, $@) -o $@

$(x86_64_c_object_files): build/x86_64/%.o : src/impl/x86_64/%.c
	mkdir -p $(dir $@) && \
	x86_64-elf-gcc -c -I src/interfaces -ffreestanding $(patsubst build/x86_64/%.o, src/impl/x86_64/%.c, $@) -o $@

.PHONY: build-x86_64
build-x86_64: $(x86_64_object_files) $(kernel_object_files)
	mkdir -p dist/x86_64 && \
	x86_64-elf-ld -n -o dist/x86_64/kernel.bin -T targets/x86_64/linker.ld $(x86_64_object_files) $(kernel_object_files) && \
	cp dist/x86_64/kernel.bin targets/x86_64/iso/boot/kernel.bin && \
	grub-mkrescue /usr/lib/grub/i386-pc -o dist/x86_64/kernel.iso targets/x86_64/iso

.PHONY: run-x86_64
run-x86_64:
	make clean_kernel
	docker exec compassionate_shockley make build-x86_64 ARCH=x86_64
	qemu-system-x86_64 -cdrom dist/x86_64/kernel.iso

$(arm_asm_object_files): build/arm/%.o : src/impl/arm/%.S
	mkdir -p $(dir $@) && \
	arm-none-eabi-gcc -mcpu=cortex-a7 -fpic -ffreestanding -c $(patsubst build/arm/%.o, src/impl/arm/%.S, $@) -o $@

$(arm_c_object_files): build/arm/%.o : src/impl/arm/%.c
	mkdir -p $(dir $@) && \
	arm-none-eabi-gcc -mcpu=cortex-a7 -fpic -ffreestanding -std=gnu99 -Wall -Wextra -I src/interfaces -c $(patsubst build/arm/%.o, src/impl/arm/%.c, $@) -o $@

.PHONY: build-arm
build-arm: $(arm_object_files) $(kernel_object_files)
	mkdir -p dist/arm && \
	arm-none-eabi-gcc -T targets/arm/linker.ld -o dist/arm/mateos.elf -ffreestanding -O2 -nostdlib $(arm_object_files) $(kernel_object_files)

.PHONY: run-arm
run-arm:
	make clean_kernel
	make build-arm ARCH=arm
	qemu-system-arm -m 1024 -M raspi2 -serial stdio -kernel dist/arm/mateos.elf

.PHONY: run
run:
	test "$(ARCH)" = "x86_64" && make run-x86_64 || \
	(test "$(ARCH)" = "arm" && make run-arm)
