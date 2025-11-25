#!/bin/bash
# Run after packer build
qemu-img info output-qemu/*.qcow2
echo "Golden image ready – test with: qemu-system-x86_64 -drive file=output-qcow2.qcow2,format=qcow2 -m 8G -enable-kvm"
