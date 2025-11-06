#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');
const { promisify } = require('util');

const execAsync = promisify(exec);

async function traverseAllSubDirectories(rootPath, command, silent = false) {
  const entries = fs.readdirSync(rootPath, { withFileTypes: true });
  
  const subdirPromises = [];
  for (const entry of entries) {
    if (entry.isDirectory()) {
      const fullPath = path.join(rootPath, entry.name);
      subdirPromises.push(traverseAllSubDirectories(fullPath, command, silent));
    }
  }
  
  await Promise.all(subdirPromises);
  
  await executeBashCommand(rootPath, command, silent);
  return null;
}

async function executeBashCommand(directory, command, silent = false) {
  try {
    console.log(`Executing in ${directory}\n`);
    const { stdout, stderr } = await execAsync(command, { 
      cwd: directory, 
      encoding: 'utf8'
    });
    if (!silent) {
      if (stdout) console.log(stdout);
      if (stderr) console.error(stderr);
    }
  } catch (error) {
    console.error(`Error in ${directory}:`, error.message);
  }
}

async function main() {
  const args = process.argv.slice(2);
  
  let rootPath, command, silent = false;
  
  // Check for --silent flag
  const silentIndex = args.indexOf('--silent');
  if (silentIndex !== -1) {
    silent = true;
    args.splice(silentIndex, 1);
  }
  
  if (args.length === 1) {
    rootPath = process.cwd();
    command = args[0];
  } else if (args.length === 2) {
    rootPath = args[0];
    command = args[1];
  } else {
    console.error('Usage: node recursive-command.js [--silent] [path] <command>');
    console.error('Example: node recursive-command.js "ls" or node recursive-command.js --silent /path/to/start "git status"');
    process.exit(1);
  }
  
  if (!fs.existsSync(rootPath)) {
    console.error(`Path does not exist: ${rootPath}`);
    process.exit(1);
  }
  
  if (!fs.statSync(rootPath).isDirectory()) {
    console.error(`Path is not a directory: ${rootPath}`);
    process.exit(1);
  }
  
  console.log(`Starting recursive traversal from: ${rootPath}`);
  console.log(`Command to execute: ${command}`);
  
  await traverseAllSubDirectories(rootPath, command, silent);
  return null;
}

main();
