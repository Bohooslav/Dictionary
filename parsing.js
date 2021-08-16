let paragraphs = document.getElementsByTagName("p");

let words = [];
for (index in paragraphs) {
  let paragraph = paragraphs[index];
  if (paragraph.innerText) {
    if (!paragraph.innerText.indexOf("•")) {
      words.push(paragraph.innerHTML);
    } else {
      words[words.length - 1] += paragraph.innerHTML;
    }
  }
}

console.log(words)