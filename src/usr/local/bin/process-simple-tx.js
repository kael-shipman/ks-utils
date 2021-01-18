#!/usr/bin/env nodejs

const fs = require("fs");

const [ input, _startDate ] = process.argv.slice(2);
if (!input) {
  console.error(`You must provide an input filename as the first argument to this script.`);
  process.exit(5);
}

let startDate = null;
if (_startDate) {
  startDate = new Date(_startDate.replace(/-/g, '/'));
  if (startDate.toString() === "Invalid Date") {
    console.error(
      `You've passed a date limit that appears not to be valid. The second argument to this ` +
      `script is an optional date that specifies when to start aggregating records. For example, ` +
      `'process-simple-tx.js /tmp/my-file.csv "2020-01-01"' would produce a file with records ` +
      `more recent than 2020-01-01 00:00:00 UTC.`
    );
    process.exit(20);
  }
}

let inputLines = fs.readFileSync(input, "utf8").split(/[\n\r]+/);
if (inputLines.length === 0) {
  console.error(`No lines found in file ${input}.`);
  process.exit(10);
}

const header = inputLines.shift() + ",debit,credit";

for (let i = 0; i < inputLines.length; i++) {
  const line = inputLines[i].split(",");
  const amount = Number(line[3]);
  const debit = amount < 0 ? amount/-1 : "";
  const credit = amount > 0 ? amount : "";
  inputLines[i] += `,${debit},${credit}`;
}

if (startDate) {
  inputLines = inputLines.filter(l => {
    const line = l.split(",");
    const date = new Date(line[0]);
    return date.getTime() >= startDate.getTime();
  });
}

const filenameParts = input.split(".");
const ending = filenameParts.pop();
filenameParts.push(`processed`, ending);
const output = filenameParts.join(".");

inputLines.unshift(header);

fs.writeFileSync(output, inputLines.join("\n"));
console.log(`Processed file written at ${output}`);

