---
layout: archive
title: "CV"
permalink: /cv/
author_profile: true
redirect_from:
  - /resume
---

{% include base_path %}

# Jared Frazier

📧 [jaredfrazierapplications [at] gmail [dot] com](mailto:jaredfrazierapplications [at] gmail [dot] com)  
💻 [github.com/jfdev001](https://github.com/jfdev001)

---

## Profile
Software engineer with 2 years of experience in high performance computing (HPC) environments, working on large-scale simulation software such as
the ICON climate/weather model. Experienced in performance optimization, automation, and DevOps

---

## Education
**Master of Science (M.Sc.): Computational Science**  
University of Amsterdam (UvA) / Vrije Universiteit (VU)  
*2024*

**Bachelor of Science (B.S.): Computer Science**  
Middle Tennessee State University (MTSU)  
*2022*

---

## Experience

**Research Software Engineer – Leibniz Institute of Atmospheric Physics (IAP)**  
*October 2024 – Present*  
- Improved efficiency of terabyte-scale climate data processing pipelines (e.g., reduced 4-hour runtime to minutes).
- Implemented significant build system and CI improvements (e.g., reduced runtime by 50%) in **FTorch**, a leading open source scientific machine learning library, and supported subsequent integration of PyTorch-based machine learning models into the ICON weather and climate model ([PRs](https://github.com/Cambridge-ICCS/FTorch/pulls?q=is%3Apr+is%3Aclosed+review%3Aapproved+author%3A%40me)).
- Standardized internal development processes by introducing GitLab-based version control and deployed a lightweight GitLab runner on a Raspberry Pi to support static analyses (e.g., executes in seconds on production-grade HPC codebases with 500k+ lines of code) and internal automation workflows ([blog](https://jfdev001.github.io/posts/2026/02/gitlab-runner-on-raspberry-pi/)).
- Designed and implemented parallelized data-processing and visualization pipelines for terabyte-scale climate datasets, leveraging GNU Parallel on Linux-based HPC systems to automate analysis and generate [publication-ready figures](https://link.springer.com/article/10.1007/s10712-025-09915-6#Ack1).
- Authored 8,000+ words of structured onboarding documentation for scientific developers, covering HPC workflows, ICON compilation/debugging, SLURM scheduling, data management, and Linux-based development practices.

**M.Sc. Thesis: Discretization of Mechanical Metamaterials on Large-Scale Parallel Computers**  
*Nov 2023 – Aug 2024*  
- Co-developed distributed meshing algorithms for the simulation of metamaterials via finite element methods and domain decomposition methods.  
- See: [GalerkinToolkit.jl](https://github.com/)  

**Intern for Imaging Biomarkers and Computer-Aided Diagnosis – National Institutes of Health**  
*Jun 2022 – Aug 2022*  
- Conducted full-time machine learning research funded by NIH.  
- Developed state-of-the-art computer vision models for 3D universal lesion detection in CT scans using the MMDetection framework.
- Wrote and submitted [conference paper](https://ui.adsabs.harvard.edu/abs/2023SPIE12465E..38F/abstract) describing improvement over state-of-the-art.

**B.S. Thesis: Machine Learning in Atmospheric Science**  
*Aug 2021 – Mar 2022*  
- Implemented linear regression, random forest, LSTM/GRU RNNs, and CNNs for multi-step ambient temperature prediction on Mars using Curiosity Rover weather data.  

**NSF REU: Machine Learning in Drug Design – University of Michigan**  
*Jun 2021 – Aug 2021*  
- Implemented variational autoencoders for mapping discrete molecular representations to continuous representations.  

<span id="foss"></span>
**Nano/Forensic Chemistry Research Assistant – MTSU**  
*Jan 2019 – Aug 2020*  
- Designed experiments and collected data using direct analysis in real time (DART) ambient ionization with mass spectrometry.  
- Authored two manuscripts and coauthored several others (see publications).  


---

## Free and Open Source Software (FOSS) Contributions

### FTorch | 10+ merged pull-requests to one of the most popular production-grade Fortran/PyTorch interoperability libraries 

- Designed and deployed GitHub Actions CI/CD pipelines for Intel oneAPI and GCC toolchains, expanding multi-compiler support and improving cross-platform build reliability ([PRs](https://github.com/Cambridge-ICCS/FTorch/pulls?q=is%3Apr+author%3Ajfdev001+is%3Aclosed+438+449)).
- Implemented automatic pkg-config file generation, simplifying library integration into legacy build systems ([PR](https://github.com/Cambridge-ICCS/FTorch/pull/464)).
- Enabled static library builds, allowing deployment in operational models where dynamic linking is restricted ([PR](https://github.com/Cambridge-ICCS/FTorch/pull/448)).
- Diagnosed and resolved subtle compilation issues, improving test-suite stability and build reproducibility ([PRs](https://github.com/Cambridge-ICCS/FTorch/pulls?q=is%3Apr+author%3Ajfdev001+is%3Aclosed+431+434+437+450)).
- Provided ongoing maintenance and community support ([all PRs](https://github.com/Cambridge-ICCS/FTorch/pulls?q=is%3Apr+author%3A%40me+is%3Aclosed), [all issues](https://github.com/Cambridge-ICCS/FTorch/issues?q=is%3Aissue%20author%3A%40me)).

### Other Open Source Contributions | 10+ merged pull-requests and issues to scientific computing projects in C, Fortran, and Julia

- **Ferrite.jl**: Improved developer documentation and resolved broken links, enhancing library usability ([PRs](https://github.com/Ferrite-FEM/Ferrite.jl/pulls?q=is%3Apr+is%3Aclosed+author%3Ajfdev001), [issues](https://github.com/Ferrite-FEM/Ferrite.jl/issues?q=is%3Aissue%20state%3Aopen%20author%3Ajfdev001)).
- **PETSc**: Corrected API documentation and tutorial examples for the world's most widely used parallel numerical software library ([PRs](https://gitlab.com/petsc/petsc/-/merge_requests/?sort=created_date&state=merged&author_username=jfdev001&first_page_size=20)).
- **fftpack**: Refactored CMake-based build system to remove unused configuration logic ([PR](https://github.com/fortran-lang/fftpack/pulls?q=is%3Apr+author%3Ajfdev001+review%3Aapproved)).
- **pFUnit**: Identified and reported dependency edge-case failures affecting downstream HPC projects ([issues](https://github.com/Goddard-Fortran-Ecosystem/pFUnit/issues?q=is%3Aissue%20author%3Ajfdev001)).
- **SpeedyWeather.jl**: Identified 5 reproducibility issues in documented examples, improving scientific correctness ([issues](https://github.com/SpeedyWeather/SpeedyWeather.jl/issues?q=is%3Aissue%20state%3Aopen%20author%3Ajfdev001)).

---

## Skills
- **Coding:** 
    - Working Knowledge: Python, C, Fortran, Bash, Julia
    - Basic Knowledge: C++, R, Mathematica, MATLAB

- **Technologies:** 
    - HPC: MPI, OpenMP, OpenACC\*, CUDA\*, Slurm
    - Version Control: Git
    - Code Collaboration: GitHub, GitLab
    - Build: CMake, Make, GNU Autotools
    - Compilers: gcc, gfortran, ifx/ifort
    - Debuggers and Analysis: gdb, pdb, valgrind
    - Libraries: TensorFlow, PyTorch, NumPy, Pandas, xarray, NetCDF, Matplotlib, Eigen3
    - OS: Linux (e.g., Ubuntu, Red Hat), Windows
    - Containerization: Docker
    - Miscellaneous: CI/CD (e.g., GitHub Actions), Prompting LLMs (e.g., ChatGPT), nvim, tmux

- **Languages:** English (native), German (B1+\*\*), Dutch (B1+\*\*), Italian (A2\*\*) 

\*Basic Knowledge, \*\*Estimated CEFR Proficiency

---

## Publications
1. Frazier, J., Mathai, T.S., Liu, J., Paul, A., & Summers, R.M. (2023). *SPIE Medical Imaging*. doi: 10.1117/12.2655250.  
2. Mahjour, B., Bench, J., Zhang, R., Frazier, J., & Cernak, T. (2023). *RSC: Digital Discovery*. doi: 10.1039/D3DD00008G.  
3. Frazier, J., Cavey, K., Coil, S., Hamo, H., Zhang, M., & Van Patten, P. G. (2021). *Langmuir*, 37 (50), 14703-14712.  
4. Tilluck, R., Mohan N., Hetherington, C., Leslie, C., Sourav, S., Frazier, J., et al. (2021). *J. Phys. Chem. Lett.*, 12, 9677-9683.  
5. Liang, J., Sun, J., Chen, P., Frazier, J., Benefield, V., & Zhang, M. (2021). *Food Research International*, 140, 109877.  
6. Frazier, J., Benefield, V., & Zhang, M. (2020). *Forensic Chemistry*, 18, 100233.  
7. Liang, J., Frazier, J., Benefield, V., Chong, N. S., & Zhang, M. (2019). *Analytical Chemistry*, 92(2), 1925–1933.  

---

## Conference Presentations
1. Frazier, J. (2021). *Blue Mars Initiative: Developing Linear Regression and Artificial Neural Network Models to Forecast Mesoscale Martian Weather Conditions*. National Council on Undergraduate Research (Virtual).  
2. Frazier, J. (2020). *Practical Investigation of Direct Analysis in Real Time Mass Spectrometry for Fast Screening of Explosives*. Posters at the Capitol, Nashville, TN.  
3. Frazier, J. (2019). *Fast Screening of Explosives by Direct Analysis in Real Time Mass Spectrometry*. 67th ASMS Conference, Atlanta, GA.  

---

## Key Graduate-Level Coursework
- Uncertainty Quantification – 8.5/10  
- Bioinformatics I (Dynamical Systems modelling) – 8.5/10  
- Data Mining Techniques – 9/10  
- Programming Multi-Core & Many-Core Systems – 7.5/10  
- Parallel Programming Practical – 8.0/10  
- Numerical Algorithms – 8.5/10  
- Programming Large-Scale Parallel Systems – 8.5/10  

---

## Academic Honors and Awards
- **Amsterdam Merit Scholarship (2022 – 2024):** The most prestigious merit scholarship at the University of Amsterdam, awarded to only 1–2 science master’s students outside EU/EEA each year.  
- **Goldwater Scholarship (2020 – 2022):** One of the most prestigious, nationally competitive U.S. scholarships supporting future leaders in natural sciences, engineering, and mathematics.  
- **DAAD RISE Scholarship (2020, Canceled due to COVID-19):** Research internship with Forschungszentrum Jülich / Helmholtz Institute for Renewable Energy (IEK-11).  

---

## Media Coverage
- **MTSU Alumni Spotlight** (July 2025) [An Atmosphere of Change – Feature on Involvement as Research Software Engineer at Leibniz Institute of Atmospheric Physics](https://issuu.com/mtsumag/docs/mtsuresearch2025/s/88674928).
- **MTSU True Blue Mars Magazine Feature** (July 2021) – [Feature on Machine Learning Research for Martian Colonization](https://mtsunews.com/blue-mars/).
- **MTSU Out of the Blue Interview – Blue Mars Initiative** (July 2021) – [Interview with VP for Marketing and Communications](https://www.youtube.com/watch?v=qKyci68yUVc).
- **Goldwater Scholar Coverage by MTSU News & Rutherford Source** (Apr 2020) – [Local news coverage of Goldwater Scholarship Achievements](https://rutherfordsource.com/mtsu-rising-junior-earns-prestigious-barry-m-goldwater-scholarship/).


