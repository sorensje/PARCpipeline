#!/bin/tcsh -xef

cd /Users/Jim/PARC_study/batch_afni
echo `pwd`

foreach subj (PARC_sub_2718 PARC_sub_2726 PARC_sub_2747 PARC_sub_2754 PARC_sub_2761 PARC_sub_2784 PARC_sub_2786 PARC_sub_2787 PARC_sub_2788 PARC_sub_2792 PARC_sub_2796 PARC_sub_2799)
	tcsh -xef reml_estimate.tcsh ${subj} 
end
