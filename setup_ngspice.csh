#!/bin/csh -f

# donwload ngspice from github
#git clone https://github.com/ngspice/ngspice.git

# Generate config
cd ngspice
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


