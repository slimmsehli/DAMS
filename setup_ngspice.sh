#!/bin/sh -f

# donwload ngspice from github
git clone https://github.com/ngspice/ngspice.git
cd ngspice


# Generate config
rm -rf build installation
export NGSPICE_HOME=$PWD/installation
mkdir ${NGSPICE_HOME}

./autogen.sh

# Configure
mkdir build
cd build
export CFLAGS="-std=gnu17"
../configure \
    --prefix=${NGSPICE_HOME} CFLAGS="-std=gnu17"
    #--enable-xspice \
    #--enable-cider \
    #--with-ngshared \
    #--with-readline=yes \
    #--with-x \
    #--exec-prefix=${NGSPICE_HOME}
    #CFLAGS="-m64-O2" LDFLAGS="-m64-s"



# Compile
make clean
make -j`nproc`

#Install localy
make install prefix=${NGSPICE_HOME} -j`nproc`
setenv PATH ${NGSPICE_HOME}/bin:$PATH

#Verify 
#ngspice -v
#find $NGSPICE_HOME -name "libngspice.so*"
#ldd $NGSPICE_HOME/lib/libngspice.so

export shared=0

if ( $shared == 1) begin
	sed -i 's/sys_errlist\[errno\]/strerror(errno)/g' src/include/ngspice/ngspice.h
	sed -i 's/pthread_exit(1)/pthread_exit((void *)(long)1)/g' src/sharedspice.c

	export temp_install=$PWD/installation_shared
	rm -rf ${temp_install}
	mkdir -p ${temp_install}

	rm -rf build_shared
	mkdir build_shared
	cd build_shared

	../configure --with-ngshared --enable-xspice --enable-cider --enable-openmp --disable-debug CFLAGS="-std=gnu17" --prefix=${temp_install}

	# Compile
	make clean
	make -j`nproc`

	#Install localy
	make install prefix=${temp_install} -j`nproc`
endif












