#!/bin/tcsh

  3dMEMA   -prefix hit-miss  \
            -jobs 2      \
            -groups CTL MDD  \
            -set   CTLs \
				PARC_sub_2699	stats.PARC_sub_2699+tlrc'[#5 C-M#0_Coef]'	stats.PARC_sub_2699+tlrc'[#6 C-M_Fstat]' \
				PARC_sub_2754	stats.PARC_sub_2754+tlrc'[#5 C-M#0_Coef]'	stats.PARC_sub_2754+tlrc'[#6 C-M_Fstat]' \
				PARC_sub_2784	stats.PARC_sub_2784+tlrc'[#5 C-M#0_Coef]'	stats.PARC_sub_2784+tlrc'[#6 C-M_Fstat]' \
				PARC_sub_2786	stats.PARC_sub_2786+tlrc'[#5 C-M#0_Coef]'	stats.PARC_sub_2786+tlrc'[#6 C-M_Fstat]' \
				PARC_sub_2792	stats.PARC_sub_2792+tlrc'[#5 C-M#0_Coef]'	stats.PARC_sub_2792+tlrc'[#6 C-M_Fstat]' \
				PARC_sub_2796	stats.PARC_sub_2796+tlrc'[#5 C-M#0_Coef]'	stats.PARC_sub_2796+tlrc'[#6 C-M_Fstat]' \
            -set   MDDs \
				PARC_sub_2718	stats.PARC_sub_2718+tlrc'[#5 C-M#0_Coef]'	stats.PARC_sub_2718+tlrc'[#6 C-M_Fstat]' \
				PARC_sub_2747	stats.PARC_sub_2747+tlrc'[#5 C-M#0_Coef]'	stats.PARC_sub_2747+tlrc'[#6 C-M_Fstat]' \
				PARC_sub_2761	stats.PARC_sub_2761+tlrc'[#5 C-M#0_Coef]'	stats.PARC_sub_2761+tlrc'[#6 C-M_Fstat]' \
				PARC_sub_2787	stats.PARC_sub_2787+tlrc'[#5 C-M#0_Coef]'	stats.PARC_sub_2787+tlrc'[#6 C-M_Fstat]' \
				PARC_sub_2788	stats.PARC_sub_2788+tlrc'[#5 C-M#0_Coef]'	stats.PARC_sub_2788+tlrc'[#6 C-M_Fstat]' \
				PARC_sub_2799	stats.PARC_sub_2799+tlrc'[#5 C-M#0_Coef]'	stats.PARC_sub_2799+tlrc'[#6 C-M_Fstat]' \
            -n_nonzero 12   \
            -HKtest         \
            -model_outliers \
            -unequal_variance \
            -residual_Z     \
 