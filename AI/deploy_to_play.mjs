import { spawn } from 'child_process';

const PACKAGE = 'com.gkquiz.india.quiz_app';
const VERSION_CODE = 1;
const LANG = 'en-IN';

// ── Store content ──────────────────────────────────────────────────────────

const TITLE = 'GK Quiz - General Knowledge';

const SHORT_DESC = 'Practice GK daily! 1000+ MCQs on Science, History, Geography, Sports & more.';

const FULL_DESC = `🧠 GK Quiz – Your Daily General Knowledge Companion!

Challenge yourself with 1000+ carefully curated multiple-choice questions across 5 major categories. Whether you're preparing for competitive exams, school tests, or just love trivia — GK Quiz has something for everyone!

📚 CATEGORIES
• 🔬 Science – Physics, Chemistry, Biology & Technology
• 🏛️ History – Ancient, Medieval & Modern World History
• 🌍 Geography – Countries, Capitals, Rivers, Mountains & More
• 📰 Current Affairs – Stay updated with recent events
• ⚽ Sports – Cricket, Football, Olympics & World Sports

✨ FEATURES
• 1000+ High-Quality MCQ Questions
• Shuffled questions every session — never the same quiz twice!
• Instant answer feedback with correct answer reveal
• Detailed score & performance summary after each quiz
• Category-wise practice mode
• Clean, distraction-free UI with dark-friendly design
• 100% Offline — no internet required to play!
• Completely Free to play

🏆 PERFECT FOR
• UPSC, SSC, Railway, Bank PO aspirants
• School and college students
• Quiz competition preparation
• General knowledge improvement
• Fun trivia challenges with friends

📈 TRACK YOUR PROGRESS
See your score improve with each quiz session. Identify weak areas by category and focus your study efforts where they matter most.

🎯 HOW TO PLAY
1. Select a category or play All Categories
2. Answer 10 shuffled questions per round
3. See your score & review answers
4. Keep improving — aim for 10/10!

Download GK Quiz now and make learning fun! 🎉

Note: This app contains ads to keep it free for everyone.`;

const RELEASE_NOTES = `🎉 Initial Release — Version 1.0

What's included:
• 1000+ MCQ questions across 5 categories
• Science, History, Geography, Current Affairs & Sports
• Shuffled questions for fresh experience every time
• Instant feedback with score summary
• Clean, modern UI optimised for Android

Thank you for downloading GK Quiz! Rate us if you enjoy it ⭐`;

// ── MCP runner ─────────────────────────────────────────────────────────────

const mcp = spawn('node', [
  'C:/Users/LENOVO/AppData/Roaming/npm/node_modules/google-play-developer-mcp/dist/index.js'
], { stdio: ['pipe', 'pipe', 'pipe'] });

let buf = '', msgId = 0, step = 0, editId = null;

function send(method, params) {
  msgId++;
  mcp.stdin.write(JSON.stringify({ jsonrpc: '2.0', id: msgId, method, params }) + '\n');
}
function callTool(name, args) { send('tools/call', { name, arguments: args }); }

function handleResponse(msg) {
  const rawText = msg.result?.content?.[0]?.text;
  let data; try { data = rawText ? JSON.parse(rawText) : null; } catch(e) { data = rawText; }

  step++;
  const isError = (Array.isArray(data) && data[0]?.code) ||
                  (typeof data === 'string' && data.includes('400'));

  console.log(`\n=== Step ${step}: ${isError ? '❌ ERROR' : '✅ OK'} ===`);
  console.log(rawText ? rawText.substring(0, 400) : JSON.stringify(msg, null, 2).substring(0, 400));

  if (isError && step > 1) {
    console.error('\nFailed. Check error above.');
    // Don't exit — continue to see what else works
  }

  if (step === 1) {
    // Init → open edit
    console.log('\n[1/6] Opening edit...');
    callTool('edits_insert', { packageName: PACKAGE });

  } else if (step === 2) {
    // Edit opened → update store listing
    editId = data?.id;
    console.log(`\n[2/6] Edit ID: ${editId}`);
    console.log('[3/6] Updating store listing (title + descriptions)...');
    callTool('listings_update', {
      packageName: PACKAGE,
      editId: editId,
      language: LANG,
      title: TITLE,
      shortDescription: SHORT_DESC,
      fullDescription: FULL_DESC,
    });

  } else if (step === 3) {
    // Listing updated → set production track
    console.log('\n[4/6] Setting production track...');
    callTool('tracks_update', {
      packageName: PACKAGE,
      editId: editId,
      track: 'production',
      releases: [
        {
          versionCodes: [VERSION_CODE],
          status: 'completed',
          releaseNotes: [{ language: LANG, text: RELEASE_NOTES }]
        }
      ]
    });

  } else if (step === 4) {
    // Track set → commit
    console.log('\n[5/6] Committing edit to Play Store...');
    callTool('edits_commit', {
      packageName: PACKAGE,
      editId: editId,
      changesNotSentForReview: false
    });

  } else if (step === 5) {
    // Done
    const success = data?.id || !isError;
    console.log('\n' + '═'.repeat(50));
    if (success) {
      console.log('🎉 APP SUBMITTED TO PLAY STORE!');
      console.log('');
      console.log('  Package:       ' + PACKAGE);
      console.log('  Version Code:  ' + VERSION_CODE);
      console.log('  Track:         Production');
      console.log('  Status:        Under Review');
      console.log('  Language:      en-IN');
      console.log('');
      console.log('Google will review the app (usually 1–3 days).');
      console.log('You will get an email when it goes live!');
    } else {
      console.log('⚠️  Partial success — check errors above.');
      console.log('Some manual steps may be needed in Play Console.');
    }
    console.log('═'.repeat(50));
    mcp.kill(); process.exit(0);
  }
}

console.log('═'.repeat(50));
console.log('GK Quiz — Play Store Release Script');
console.log('Package: ' + PACKAGE);
console.log('═'.repeat(50));

send('initialize', {
  protocolVersion: '2024-11-05',
  capabilities: {},
  clientInfo: { name: 'gkquiz-release', version: '1.0' }
});

mcp.stdout.on('data', d => {
  buf += d.toString();
  const lines = buf.split('\n'); buf = lines.pop();
  for (const l of lines) {
    if (!l.trim()) continue;
    try { const m = JSON.parse(l); if (m.id !== undefined) handleResponse(m); } catch(e) {}
  }
});
mcp.stderr.on('data', d => process.stderr.write(d));
setTimeout(() => { console.error('TIMEOUT after 2 min'); mcp.kill(); process.exit(1); }, 120000);
