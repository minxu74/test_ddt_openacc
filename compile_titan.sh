#!/usr/bin/env bash

module load pgi
module load cudatoolkit


ftn -Minfo=accel -ta=tesla:deepcopy dc_openacc.f90 -o DC_OPENACC.exe
ftn -Minfo=accel -ta=tesla:deepcopy acc_detach_enter_exist.f90 -o ACC_DETACH.exe
