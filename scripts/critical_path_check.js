#!/usr/bin/env node
/**
 * Critical Path Check
 * Validates that PRs answer the critical path question
 */

const CRITICAL_PATH_QUESTION = "Is this effort on the critical path to getting a functional MVP on Render.com?";

async function checkPullRequest({ github, context }) {
  if (!context.payload.pull_request) {
    console.log('Not a pull request event, skipping...');
    return;
  }

  const { owner, repo } = context.repo;
  const prNumber = context.payload.pull_request.number;
  const prBody = context.payload.pull_request.body || '';

  console.log(`Checking PR #${prNumber}...`);

  // Check for the critical path checkbox
  const checkboxPattern = /- \[(x| )\] Is this effort on the critical path/i;
  const checkboxMatch = prBody.match(checkboxPattern);

  if (!checkboxMatch) {
    console.log('❌ Critical path checkbox not found in PR description');
    await addComment(github, owner, repo, prNumber,
      `⚠️ **Critical Path Check Missing**\n\n` +
      `Please include the critical path question in your PR description:\n\n` +
      `\`\`\`\n- [ ] ${CRITICAL_PATH_QUESTION}\n\`\`\``
    );
    throw new Error('Critical path checkbox missing');
  }

  const isChecked = checkboxMatch[1] === 'x';

  if (!isChecked) {
    console.log('❌ Critical path checkbox is not checked');
    await addComment(github, owner, repo, prNumber,
      `⚠️ **Critical Path Question Unanswered**\n\n` +
      `Please check the box and provide an explanation for:\n\n` +
      `**${CRITICAL_PATH_QUESTION}**`
    );
    throw new Error('Critical path checkbox not checked');
  }

  // Check for explanation after the checkbox
  const lines = prBody.split('\n');
  let foundCheckbox = false;
  let explanation = '';

  for (const line of lines) {
    if (foundCheckbox && line.trim() && !line.startsWith('#') && !line.startsWith('-')) {
      explanation += line.trim() + ' ';
    }
    if (checkboxPattern.test(line)) {
      foundCheckbox = true;
    }
    if (foundCheckbox && line.startsWith('---')) {
      break;  // End of section
    }
  }

  explanation = explanation.trim();

  if (!explanation || explanation.length < 10) {
    console.log('❌ Critical path explanation is missing or too short');
    await addComment(github, owner, repo, prNumber,
      `⚠️ **Critical Path Explanation Required**\n\n` +
      `You've checked the box, but please provide a brief explanation:\n\n` +
      `- If YES: How does this work contribute to the MVP on Render?\n` +
      `- If NO: Why is this being included now? Should it be behind a feature flag?`
    );
    throw new Error('Critical path explanation missing or insufficient');
  }

  console.log(`✅ Critical path check passed`);
  console.log(`Explanation: ${explanation}`);

  // Optionally add a label based on the answer
  const isOnCriticalPath = /\b(yes|critical|mvp|blocking|required)\b/i.test(explanation);
  const label = isOnCriticalPath ? 'critical-path' : 'defer-after-mvp';

  try {
    await github.rest.issues.addLabels({
      owner,
      repo,
      issue_number: prNumber,
      labels: [label]
    });
    console.log(`Added label: ${label}`);
  } catch (error) {
    console.log(`Could not add label (may not exist): ${error.message}`);
  }
}

async function addComment(github, owner, repo, prNumber, body) {
  try {
    await github.rest.issues.createComment({
      owner,
      repo,
      issue_number: prNumber,
      body
    });
  } catch (error) {
    console.error(`Failed to add comment: ${error.message}`);
  }
}

// Export for GitHub Actions
module.exports = checkPullRequest;

// Allow running standalone
if (require.main === module) {
  console.log('Critical Path Check');
  console.log('This script should be run via GitHub Actions with github-script');
  process.exit(1);
}
