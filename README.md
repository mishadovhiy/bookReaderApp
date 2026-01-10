<div style="display:flex">
<img width="40%" src="https://github.com/user-attachments/assets/8d85b07f-c67a-428b-aab1-21a5f8a123b8" />
  <img width="40%" src="https://github.com/user-attachments/assets/5e21275d-4b91-4218-b1ab-3f081d80db3d" />
</div>

https://github.com/user-attachments/assets/beda585b-a9f9-42ad-b7fe-2258e2dc25a0

## Functionalities
- Fetch json representable book from URL and store response in cache
- <b>Swipe</b> between pages and scroll inside selected chapter
- Tap on word to <b>save word as bookmark</b>
- <b>Save reading progress</b> to the local database. <small>Additionally saved tags for specific chapters are displayed on the home screen as a number - count of tags at chapter</small>
- Select chapter from home screen ability (on the home screen, in chapters section, displayed titles for all chapters that are not saved as "currently reading", because to the currently reading chapter user gets by pressing resume reading)
- <b>Continue reading button</b> - takes to the last reading chapter and scrolls to the last reading paragraph, or to the first chapter to the beginning of the page if nothing was saved to the reading progress

<div style="display:flex">
<p><b>Local database</b> - implemented with CoreData<br><small>(stores reading progress, tapped tags)</small></p>

<p width="30%"><b>Minimum WatchOS version</b>: 9.0</p>

<p width="30%"><b>Architecture</b>: MVVM</p>

</div>


Additionally implemented static text on home screen, under continiue reading button. Text stays statically on the screen during the scroll, and presents limited amount of characters, from limited about of chapters
