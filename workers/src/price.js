const uuid = require("uuid/v4");
const helper = require("./helper.js");
const dataset = require("./dataset.json");
const config = require("./config.js");

const koor = require("./koordinator.js");

const namespace = "Demo";
const name = "Price";

koor.postCatalog({
  namespace: namespace,
  name: name,
  displayName: name,
  inputs: [
    {
      name: "type",
      baseType: "string"
    },
    {
      name: "name",
      baseType: "string"
    },
    {
      name: "asOf",
      baseType: "string"
    },
    {
      name: "id_pricing",
      baseType: "string"
    }
  ],
  outputs: [
    {
      name: "pricedElements",
      baseType: "String",
      allowMultipleValues: true
    }
  ],
  versionNumber: 4,
  schemaVersion: 0
});

function referencesUnavailableDesk(type, name) {
  if (type === "Desk" && name === "Volatility_error") return true;
  if (type === "Portfolio" && dataset["Volatility_error"].includes(name))
    return true;
  return false;
}

function minorPricingProblems(type, name) {
  if (type === "Desk" && name === "Equity Finance") return true;
  if (type === "Portfolio" && name === "Inventory") return true;
  return false;
}

koor.pollingLoop(namespace, name, async task => {
  const inputType = task.inputData.type;
  const inputName = task.inputData.name;

  if (referencesUnavailableDesk(inputType, inputName)) {
    await koor.postStatus(task, {
      status: "Error",
      errorLevel: "Fatal",
      message: `Desk Volatility_error unavailable`
    });
    return;
  }

  await koor.postStatus(task, {
    status: "InProgress",
    message: `Starting pricing ${task.inputData.id_pricing}...`
  });

  if (minorPricingProblems(inputType, inputName)) {
    await koor.postStatus(task, {
      status: "Error",
      errorLevel: "Minor",
      message: `ERROR: Missing market data for ${inputType}: ${inputName}!`
    });
  }

  var pricedElements = task.previousOutputData
    ? task.previousOutputData.pricedElements
    : [];

  if (inputType === "Desk" && inputName === "DLP") {
    var elementToPrice = dataset[inputName][pricedElements.length];
    pricedElements.push(elementToPrice);

    const progressMin = parseInt(
      ((pricedElements.length - 1) / dataset[inputName].length) * 100,
      10
    );
    const progressMax = parseInt(
      (pricedElements.length / dataset[inputName].length) * 100,
      10
    );

    for (i = progressMin; i <= progressMax; i++) {
      await koor.postStatus(task, {
        status: "InProgress",
        message: `Pricing of ${elementToPrice} in progress`,
        progressPercentage: i
      });
    }

    if (pricedElements.length !== dataset[inputName].length) {
      await koor.postStatus(task, {
        status: "Error",
        errorLevel: "Fatal",
        message: "Pricing not completed",
        outputValues: {
          pricedElements: pricedElements
        }
      });
      return;
    }
  } else {
    for (let index = 0; index < 100; index++) {
      await koor.postStatus(task, {
        status: "InProgress",
        message: `${index.toFixed(0)}% pricing`
      });

      index += Math.random() * 3;
      helper.longSleep();
    }
  }

  if (config.singleNode) {
    helper.readFromTopic(task.workflowInstanceId);
  }

  helper.shortSleep();

  await koor.postStatus(task, {
    status: "Completed",
    message: "Pricing DONE",
    progressPercentage: 100,
    outputValues: {
      pricedElements: pricedElements
    }
  });
});
