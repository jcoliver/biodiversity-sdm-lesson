# Species Distribution Modeling

## Troubleshooting & Tips

### Git

1. **Git installation**. There are a variety of potential issues you may 
encounter when installing Git and using it in RStudio. This set of tips is not 
exhaustive and if you encounter issues with Git, please consider finding a 
colleague with Git and RStudio experience to help you out.
    1. If you are working on a Mac you may get a security warning saying 
    something like "git-2.14.1-intel-universal-mavericks.pkg can't be opented 
    because it is from an unidentified developer". If this happens, click 
    **OK**. Then open your system preferences folder (click the Apple icon in 
    the upper-left-hand corner of the screen. Click on **Security and Privacy** 
    from the top row. At the bottom of the window you will see a message like 
    "git-2.14.1-intel-universal-mavericks.pkg was blocked from opening because 
    it is not from an identified developer" (the version of git you have 
    installed may be different; i.e. "2.14.1" may be replaced by a higher 
    version in the message you receive).  Next to it you will see a button that 
    says **Open Anyway**. Click **Open Anyway** and close the window.
    2. If you are installing Git on a Windows machine, follow the prompts of 
    the installation wizard and choose the default settings.
    3. There are considerable "opportunities" for RStudio to be unaware of the 
    location of the Git program. To check to make sure RStudio knows where to 
    look for Git, in RStudio, open **Tools > Global Options...** and click the 
    **Git/SVN** tab on the left-hand side of the dialog. This should tell you 
    where it is looking for the Git program. Make sure the value in the 
    **Git Executable** field matches the location of your Git program. What's 
    that you say? Don't know where git is installed? If you are on a Mac or a 
    Linux machine (or running bash on a Windows machine), open a Terminal and 
    type `which git`; if you are on a Windows machine (not in bash), open a 
    Terminal and type `where git`.
    4. Some additional troubleshooting tips for Git/RStudio integration can be 
    found at [http://happygitwithr.com/troubleshooting.html](http://happygitwithr.com/troubleshooting.html).
2. **Git configuration**. Before cloning a repository, it is a good idea to add 
your Git credentials for your machine. You will need to do this through a 
Terminal window (*not* the RStudio **Console**). In the terminal, enter the 
following two commands (hitting `Enter` after each one):  
`git config --global user.name 'Your Name'` (replacing "Your Name" with your actual name or user name; be sure to surround it in single quotes)  
`git config --global user.email 'your@email.com'` (replacing "your@email.com" with your actual e-mail address; be sure to surround it in single quotes).  
Note there are a number of ways to open a Terminal window. In newer versions of 
RStudio, there should be a **Terminal** tab next to the **Console** tab in the 
lower-left pane. If you do not see a **Terminal** tab, you can open one via 
**Tools > Terminal > New Terminal**. If neither of those are options, you can 
open a separate Terminal window via **Tools > Shell...**.
3. **Cloning a repository**. Briefly, to clone a repository from GitHub in 
RStudio:
    1. Start RStudio
    2. Create a new project via **File > New Project...**
    3. Select **Version Control** (likely the third option) in the Create 
    Project dialog
    4. Select **Git** (likely the first option) in the Create Project from 
    Version Control dialog
    5. In the Clone Repository dialog:
        1. In the **Repository URL** field, enter the GitHub URL for this 
        project: **https:github.com/jcoliver/biodiversity-sdm-lesson.git** 
        (note the .git extention on the URL)
        2. The **Project Name** field should be automatically filled in for you 
        (it should read "biodiversity-sdm-lesson")
        3. In the **Create project as a subdirectory of** field, use the 
        **Browse...** button to navigate to a folder of your choice. Select 
        that folder by clicking on it once and clicking the **Open** button. 
        Note, you will need to remember where you created this project, so this 
        folder should be one that is easy to find (like your Desktop).
        4. Click **Create Project**. The files will download from GitHub and be 
        available on your machine!

### R

1. R is *case sensitive*, so upper case letters mean something different than 
lower case letters. This is also true for file names. So if you save a file 
with the name "my_data.csv", but try to refer to it in R as "My_Data.csv", R 
will produce an error message (generally something like 
`"cannot find input file"` or `"no such file or directory"`).
2. Avoid setting the working directory in R (i.e. don't use the `setwd` 
command) or [Jenny Bryan will set your computer on fire](https://www.tidyverse.org/blog/2017/12/workflow-vs-script/).
3. If running the setup script (`source(file = scripts/setup.R)`) does not 
work, you should try installing the additional packages manually (see point 4, 
below, too). There are three additional packages that will need to be 
installed. To install these packages, enter the following commands into the 
R console:

        ```r
        install.packages("terra")
        install.packages("geodata")
        install.packages("predicts")
        ```
If there are still problems installing these packages, we recommend visiting 
the respective package's web resource for additional troubleshooting advice
([terra](https://cran.r-project.org/web/packages/terra/index.html),
[geodata](https://cran.r-project.org/web/packages/geodata/index.html)
[predicts](https://cran.r-project.org/web/packages/predicts/index.html)). Or 
find your nearest R guru and bribe them with cookies to help you solve the 
problem.
4. You should have a recent version of R installed; we recommend version 4.4.1 
or newer. To find out which version of R you have installed, enter this command 
on the R console: `R.Version()` (note the upper case "Version"). The version 
will be stored in the `version.string` element (which should be printed to the 
screen when you run `R.Version()`). If your version of R is older than 4.4.1, 
download the latest version from the 
[R Website](http://cran.r-project.org/mirrors.html) and restart RStudio.

### Additional resources

+ [Setup and configure R and RStudio on a Mac](https://www.youtube.com/watch?v=cmj8Oi6PFe0) (16:18)
+ [Brief navigation introduction to RStudio on a Mac](https://www.youtube.com/watch?v=bGBgjZd6YHw) (2:21)
