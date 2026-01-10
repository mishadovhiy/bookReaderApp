<div style="display:flex">
<img width="40%" src="https://github.com/user-attachments/assets/8d85b07f-c67a-428b-aab1-21a5f8a123b8" />
  <img width="40%" src="https://github.com/user-attachments/assets/5e21275d-4b91-4218-b1ab-3f081d80db3d" />
</div>

https://github.com/user-attachments/assets/beda585b-a9f9-42ad-b7fe-2258e2dc25a0

## Functionalities
<p>- Fetch json representable book from URL and store response in cache</p>
<p>- <b>Swipe</b> between pages and scroll inside selected chapter</p>
<p>- Tap on word to <b>save word as bookmark</b></p>
<p>- <b>Save reading progress</b> to the local database. <small>Additionally saved tags for specific chapters are displayed on the home screen as a number - count of tags at chapter</small></p>
<p>- Select chapter from home screen ability (on the home screen, in chapters section, displayed titles for all chapters that are not saved as "currently reading", because to the currently reading chapter user gets by pressing resume reading)</p>
<p>- <b>Continue reading button</b> - takes to the last reading chapter and scrolls to the last reading paragraph, or to the first chapter to the beginning of the page if nothing was saved to the reading progress</p>

## Overview
<div style="display:flex">
<p><b>Local database</b> - implemented with CoreData<br><small>(stores reading progress, tapped tags)</small></p>

<p width="30%"><b>Minimum WatchOS version</b>: 9.0</p>

<p width="30%"><b>Architecture</b>: MVVM</p>

</div>

## 
Additionally implemented static text on home screen, under continiue reading button. Text stays statically on the screen during the scroll, and presents limited amount of characters, from limited about of chapters

##
### Development process
1. Core Data implementation, database data model structure took most of the time, at the begining i have implemented local database storage with FileManager, but then switched to the CoreData
2. getting tapped word index and storing selected word in the database - took most of the time, during implementation of taping on word, in the begining i have user Custom URL Shema, but watchOS didn't support them and resourching for Custom URL Schema on WatchOS took also more time. I have implemented easier solution - to calculate tapped word with CGRect at tapped Point and database structure become simplier
3. Additionally have implemented text unser start button, it took additionally 3 hours to mask 
