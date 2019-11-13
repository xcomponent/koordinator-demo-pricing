const fs = require("fs");
const dir = "topics/";
const sleep = require("./sleep.js");

function randomSleep(around) {
  sleep.sleep(Number.parseInt(Math.random() * around));
}

function shortSleep() {
  randomSleep(1);
}

function longSleep() {
  randomSleep(5);
}

function writeToTopic(topic) {
  if (!fs.existsSync(dir)) {
    console.log("topics folder doesn't exist, creating it");
    fs.mkdirSync(dir);
  }

  console.log("writeToTopic", topic);
  fs.closeSync(fs.openSync(dir + topic, "w"));
}

function readFromTopic(topic) {
  while (!fs.existsSync(dir + topic)) {
    console.log("readFromTopic", topic);
    longSleep();
  }
}

module.exports = {
  shortSleep,
  longSleep,
  writeToTopic,
  readFromTopic
};
