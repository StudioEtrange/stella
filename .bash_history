ls
ldd workspace/feature_linux/ubuntu/libpng/1_6_17/lib/libpng.so 
objdump -p wworkspace/feature_linux/ubuntu/libpng/1_6_17/lib/libpng.so 
objdump -p workspace/feature_linux/ubuntu/libpng/1_6_17/lib/libpng.so 
LD_LIBRARY_PATH=/home/stella/workspace/feature_linux/ubuntu/zlib/1_2_8/stella-dep/lib/dynamic ldd workspace/feature_linux/ubuntu/libpng/1_6_17/lib/libpng.so 
ls -al /home/stella/workspace/feature_linux/ubuntu/zlib/1_2_8/stella-dep/lib/dynamic/libz.so 
chown -R stella:stella /home/stella/workspace/feature_linux/ubuntu/zlib/1_2_8/stella-dep/lib/dynamic
chown -R stella:stella /home/stella/workspace/feature_linux/ubuntu/libpng/1_6_17/lib/
LD_LIBRARY_PATH=/home/stella/workspace/feature_linux/ubuntu/zlib/1_2_8/stella-dep/lib/dynamic ldd workspace/feature_linux/ubuntu/libpng/1_6_17/lib/libpng.so 
