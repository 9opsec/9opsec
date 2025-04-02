
// https://github.com/schalkneethling/schalkneethling/blob/main/.github/workflows/update-blog-posts.yml
// add this to the package.json 
    // "readme:dryrun": "DRYRUN=1 node script/update-blog-posts.js",
    // "readme:update": "node script/update-blog-posts.js",
      
import { readFileSync, writeFileSync } from "node:fs";

import { XMLParser } from "fast-xml-parser";
import { logger } from "../utils/logger.js";

function getReadmeContent() {
  return readFileSync("README.md", "utf-8");
}

function updateReadmeContent(content) {
  writeFileSync("README.md", content, "utf-8");
}

function postsToMarkdown(posts) {
  const options = {
    day: "numeric",
    month: "long",
    timeZone: "UTC",
    weekday: "long",
    year: "numeric",
  };

  return posts
    .map((post) => {
      const pubDate = new Date(post.pubDate);
      const content = [
        `### [${post.title}](${post.link})`,
        post.description,
        pubDate.toLocaleDateString(undefined, options),
      ].join("\n\n");
      return content.trim();
    })
    .join("\n\n");
}

const main = async () => {
  const DRYRUN = Boolean(JSON.parse(process.env.DRYRUN ?? "false"));

  try {
    const response = await fetch("https://example.com/rss.xml");

    if (response.ok) {
      const data = await response.text();
      const parser = new XMLParser();
      const xml = parser.parse(data);

      const { rss } = xml;
      const entries = rss.channel.item.slice(0, 5);

      const postsContainerRegExp =
        /<!-- blog posts -->[\s\S]*<!-- \/blog posts -->/;
      const readmeContent = getReadmeContent();

      const postsAsMarkdown = postsToMarkdown(entries);
      const updatedReadmeContent = readmeContent.replace(
        postsContainerRegExp,
        `<!-- blog posts -->\n${postsAsMarkdown}\n<!-- /blog posts -->`,
      );

      if (DRYRUN) {
        logger.log(updatedReadmeContent);
      } else {
        updateReadmeContent(updatedReadmeContent);
      }
    }
  } catch (error) {
    logger.error(error);
  }
};

main();
