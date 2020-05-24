# gourmet-formalog
Prolog-based Meal Planning system w/ Recipes, Barcodes, Nutrition Information, etc

This is a work in progress, meal planning system which uses Prolog.  Currently, most of the data is integrated, although I had to truncate a lot of the data to get it to fit on github.  There are scripts that you could use to rebuild the data.  Namely, you want to extract the food data central archive into the directory with truncated files, and then run some of the scripts to build the .pl and then the .qlf.  This may depend on FRDCSA, running Gourmet-Formalog properly does depend on FRDCSA, but I will work to factor out this dependency eventually.  Then there is a file called list.txt or something that has a listing of recipe files.  The end of those filenames indicate the URLs from which they may be downloaded, I was unsure of their license and hence did not include.  But the system will convert all of the recipes it has from MealMaster and/or RecipeML into .pl and then .qlf.  Food data central and the 150K recipes will load in approx 5 seconds on my machine from .qlf.  Then the WordNet load time is longer.

Please note that I haven't finished writing the software for normalizing ingredients and other unconstrained information.  I forget the exact normalizations which must take place, I will find them and post them here.

The Meal Planning software runs on the Free Life Planner (https://github.com/aindilis/free-life-planner) and calls Gourmet-Formalog with FLP's pantry inventory in order to get nutrition information for aiding in generating compliant meal plans.

I am very happy with this system although to be blunt it is not much more than a glorified data-wrapper at this point (well that's not really fair, but) but it is a *way* better approach than were the previous Gourmet implementations, owing to how natural it is to express relational data in Prolog.
