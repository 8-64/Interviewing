const cityInfo =
  '27|Chicago|Illinois|I-94;I-90;I-88;I-57;I-55\n83|New York|New York|I-78;I-95;I-87;I-80\n15|Phoenix|Arizona|I-10;I-17;I-8\n15|Philadelphia|Pennsylvania|I-95;I-76';

// ###########----  PROBLEM 1 ------###############

function cityPopulationOrganizer(data) {
  let output = '';
  let previousPop = 0;

  // Split string into an array of city information
  const cityArr = data.split('\n');

  // Sort array by population descending
  cityArr.sort((x, y) => +x.slice(0, 2) - +y.slice(0, 2)).reverse();

  for (let i = 0; i < cityArr.length; i++) {
    let cityInfo = cityArr[i].split('|');

    //Sort interstates by numbers ascending
    let interstates = cityInfo[3]
      .split(';')
      .sort((x, y) => +x.slice(2, 4) - +y.slice(2, 4))
      .join(', ');

    // Check if the population numbers repeat from the last loop
    if (+cityInfo[0] === previousPop) {
      output += `\n\n ${cityInfo[1]}, ${
        cityInfo[2]
      }\n Interstates: ${interstates}\n`;
    } else {
      output += `\n ${cityInfo[0]} \n \n ${cityInfo[1]}, ${
        cityInfo[2]
      } \n Interstates: ${interstates}\n`;

      //Update population reference for next loop
      previousPop = +cityInfo[0];
    }
  }

  return output;
};

console.log(cityPopulationOrganizer(cityInfo));
console.log('='.repeat(80));

// ###########----  PROBLEM 2 ------###############

const interstateData =
  '4|Raleigh|North Carolina|I-40;I-85;I-95\n27|Chicago|Illinois|I-94;I-90;I-88;I-57;I-55\n2|Madison|Wisconsin|I-94;I-90';

function interstateFrequency(data) {
  let output = '';
  const sanitizedObj = {};

  for (let i = 0; i < data.length; i++) {
    //Search for hyphens, check if the following character is a number
    if (data[i] === '-' && typeof +data[i + 1] === 'number') {
      let interstateNumber;

      //Check if the Interstate is one or two digits
      if (typeof +data[i + 2] !== 'number') {
        interstateNumber = +data.slice(i + 1, i + 2);
      } else {
        interstateNumber = +data.slice(i + 1, i + 3);
      }

      //Update interstate connections or create one if it's the first instance
      if (sanitizedObj[interstateNumber]) {
        sanitizedObj[interstateNumber]++;
      } else {
        sanitizedObj[interstateNumber] = 1;
      }
    }
  }
  //Compile final string
  for (let interstate in sanitizedObj) {
    output += `I-${interstate} ${sanitizedObj[interstate]}\n`;
  }

  return output;
};

console.log(interstateFrequency(interstateData));
