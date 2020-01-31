# Run commands

docker run --restart always -p 3333:22 \
  -v [HOST_MACHINE_GRALDE_CACHE_DIR]:/root/.gradle \
  -v [HOST_MACHINE_SSH_KEYS_FILE_PATH]:/root/.ssh/authorized_keys \
  -v [HOST_MACHINE_DEBUG_KEYSTORE_PATH]:/root/.android/debug.keystore \
  -d --name man myand

docker run --restart always -p 3333:22 \
  -v ~/Documents/gradcache:/root/.gradle \
  -v ~/keys/authorized_keys:/root/.ssh/authorized_keys \
  -v ~/.android/debug.keystore:/root/.android/debug.keystore \
  -d --name man myand

# run container from docker hub image
docker run --restart always -p 3333:22 \
  -v ~/Documents/gradcache:/root/.gradle \
  -v ~/keys/authorized_keys:/root/.ssh/authorized_keys \
  -v ~/.android/debug.keystore:/root/.android/debug.keystore \
  -d --name man bodos/android_mainframer
