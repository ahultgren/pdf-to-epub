// This code is for v4 of the openai package: npmjs.com/package/openai
import OpenAI from "openai";
import fs, { readdirSync } from "fs";
import { env } from "process";

const openai = new OpenAI({
  apiKey: env.OPENAI_API_KEY,
});

const files = readdirSync("./ocr/")
  .filter((fn) => fn.endsWith(".txt"))
  .map((path) => path.split("/").pop());

for (let i in files) {
  await getAndWriteFile(files[i]);
}

async function getAndWriteFile(fileName) {
  const fileContent = fs.readFileSync(`./ocr/${fileName}`, {
    encoding: "utf8",
  });

  console.log("calling api with file...", fileName);

  try {
    const response = await openai.chat.completions.create({
      model: "gpt-4",
      messages: [
        {
          role: "system",
          content:
            "You will be provided with extracts from a scanned book, and your task is to clean up spelling and artifacts from the scanning, while leaving original wording and ellipses intact. Also, remove any page headers and page numbers. Do not capitalize the first letter in the output if it wasn't capitalized in the original.",
        },
        {
          role: "user",
          content: fileContent,
        },
      ],
      temperature: 0,
      max_tokens: 3115,
      top_p: 1,
      frequency_penalty: 0,
      presence_penalty: 0,
    });

    console.log("writing file", fileName);

    fs.writeFileSync(
      `./cleaned/${fileName}`,
      response.choices[0].message.content
    );
  } catch (e) {
    console.error(e);
    process.exit();
  }
}
