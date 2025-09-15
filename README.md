**CITATION:** <br>
If you find our code useful in your research, please cite the study of Makaram et al. (2025):<br>
```Makaram N, Pesce M, Tsuboyama M, Bolton J, Harmon J, Papadelis C, Stone SS, Pearl PL, Rotenberg A, Grant PE, Tamilia E. Targeting Interictal Low-Entropy Zones during Epilepsy Surgery Predicts Successful Outcomes in Pediatric Drug-Resistant Epilepsy. Epilepsia (In Production) 2025 ``` <br>


**HOW TO RUN ENTROPY ANALYSIS IN BRAINSTORM**

**process_entropy_NM.m** is the Brainstorm process to compute Shannon Entropy values from the signal

**Steps to use it with Brainstorm**
1) Add the file "process_entropy_NM.m" to "$HOME/.brainstorm/process/" folder
2) Once you open brainstorm you will find this code in the custom folder
3) Drag your signal into the brainstorm process tab and run the function from the custom code.
4) Apply appropriate filters before running this code to get frequency specific entropy values
