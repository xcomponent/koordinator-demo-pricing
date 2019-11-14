const uuid = require("uuid/v4");

const koor = require("./koordinator.js");
const dataset = require("./dataset.json");
const helper = require("./helper.js");

const namespace = "Demo";
const name = "InitPricing";

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
    }
  ],
  outputs: [
    {
      name: "id_pricing",
      baseType: "string"
    }
  ],
  versionNumber: 3,
  schemaVersion: 0
});

koor.pollingLoop(namespace, name, async task => {
  if (task.inputData.type === "Desk") {
    if (dataset[task.inputData.name] === undefined) {
      await koor.postStatus(task, {
        status: "Error",
        errorLevel: "Fatal",
        message: `Desk ${
          task.inputData.name
        } not found. Should be one of [${Object.keys(dataset).join(",")}] `
      });
      return;
    }
  } else if (task.inputData.type === "Portfolio") {
    const deskContainsPortfolio = (desk, toBeFoundPortfolio) =>
      dataset[desk].find(portfolio => portfolio === toBeFoundPortfolio) !==
      undefined;

    const existsDeskWithCondition = condition =>
      Object.keys(dataset).find(desk => condition(desk)) !== undefined;

    if (
      !existsDeskWithCondition(desk =>
        deskContainsPortfolio(desk, task.inputData.name)
      )
    ) {
      await koor.postStatus(task, {
        status: "Error",
        errorLevel: "Fatal",
        message: `Portfolio ${task.inputData.name} not found`
      });
      return;
    }
  } else if (task.inputData.type === "" && task.inputData.name === "") {
    // it's ok
  } else {
    await koor.postStatus(task, {
      status: "Error",
      errorLevel: "Fatal",
      message: `Type ${task.inputData.type} not found`
    });
    return;
  }

  helper.shortSleep();

  await koor.postStatus(task, {
    status: "Completed",
    outputValues: {
      id_pricing: `${task.inputData.type}_${task.inputData.name}_${
        task.inputData.asOf
      }_${uuid()}`
    }
  });
});
