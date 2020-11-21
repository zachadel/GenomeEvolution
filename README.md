# GenomeEvolution

## Important Notes:
### Report Bug Feature
- Change `env.example.json` to `env.json`
- Replace the `token` key with the correct OAuth token
- Never commit `env.json` with key

### How to Export for HTML
1. Download latest build from dev branch.
1. Open in Godot.
1. At the top, open the Project tab and select Export...
1. For export path, create a new directory/folder named <b>month_day_year</b> where month, day, and year are given numerically.
1. The name of the file MUST without exception be named <b>index.html</b>, otherwise things tend to break.
1. Now click Export Project where you'll be asked to confirm the name and where you want it to be exported.
1. Once finished exporting, navigate to the index.html file and find the line that say "Change me after exporting" and change that to "Month day, year (Build number)" where number is replaced with the build number of that day.
1. Check that your build works by following the directions at docs.godotengine.org/en/stable/getting_started/workflow/export/exporting_for_web.html.
	1. Navigate to the directory where you exported the index.html in a command prompt or terminal.
	1. Launch a local http server in that directory. If you have python installed on your machine, this is as easy as using the command python -m http.server 8000 --bind 127.0.0.1
	1. Open a web browser and type in the address bar http://localhost:8000 and verify that the build works. 
1. Once you're sure that the build works, zip that month_day_year directory and upload it to the shared folder in the Google Drive, making sure to place the zipped folder in Current Builds.
1. Remove the old build from Current Builds and place it into Old Builds.
1. Notify Dr. Adelman that the change has been completed.
