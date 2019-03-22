#!/usr/bin/env bash

module load pgi

mpif90 -Minfo=accel -ta=tesla:deepcopy dc_openacc.f90 -o DC_OPENACC.exe
mpif90 -Minfo=accel -ta=tesla:deepcopy acc_detach_enter_exist.f90 -o ACC_DETACH.exe
