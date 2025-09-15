## IEEG Entropy
This Github page contains the Brainstorm process to compute Shannon Entropy values from the iEEG signal
## Bibtex
If you find our project is useful in your research, please cite Makaram et al. (2025):
```
Makaram N, Pesce M, Tsuboyama M, Bolton J, Harmon J, Papadelis C, Stone SS, Pearl PL, Rotenberg A, Grant PE, Tamilia E. Targeting Interictal Low-Entropy Zones during Epilepsy Surgery Predicts Successful Outcomes in Pediatric Drug-Resistant Epilepsy. Epilepsia (In Production) 2025
```
## Prerequisits
- Matlab
- Brainstorm toolbox

## Usage
Download the latest code from the github page and add it to your /$HOME/.brainstorm/process/ folder.
process_entropy_NM.m 


Steps to use it with brainstorm
1) Once you open brainstorm you will find this code in the custom folder
2) Preprocess your signal appropriately and segment to epochs. If you are planning to replicate our work then apply notch and bandpass filter (1 - 500 Hz), apply bipolar montage and then import 3s epochs.
3) Drag your signal/epochs into the brainstorm process tab and run the function from the custom code.
4) This will generate a table inside the matrix output with can be exported to matlab and analysed. The generated output is also inside the Values
 which can be used for plotting.
