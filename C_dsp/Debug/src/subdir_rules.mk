################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Each subdirectory must supply rules for building sources it contributes
src/%.obj: ../src/%.c $(GEN_OPTS) | $(GEN_FILES) $(GEN_MISC_FILES)
	@echo 'Building file: "$<"'
	@echo 'Invoking: C6000 Compiler'
	"/home/preben/myApps/ti/ccs1280/ccs/tools/compiler/c6000_7.3.23/bin/cl6x" -mv6740 -g --define=c6748 --include_path="/home/preben/Documents/ee580_dsp/C_dsp" --include_path="/home/preben/Documents/ee580_dsp/C_dsp/inc" --include_path="/home/preben/myApps/ti/ccs1280/ccs/tools/compiler/c6000_7.3.23/include" --display_error_number --diag_warning=225 --abi=coffabi --preproc_with_compile --preproc_dependency="src/$(basename $(<F)).d_raw" --obj_directory="src" $(GEN_OPTS__FLAG) "$(shell echo $<)"
	@echo 'Finished building: "$<"'
	@echo ' '


