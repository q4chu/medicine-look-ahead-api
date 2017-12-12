var global = require('./global');
var db = global.mysql;

exports.searchByDin = function(din,res) {
    console.log('din number is: ' + din);
    query = "select health_canada_identifier, mp_formal_name from ccdds where health_canada_identifier = " + din + ";";
    db.exec(query,(results,fields) => {
        res.json(results);
    });
};

//tm_formal_name(category) is non-duplicate
//examine: select c1.tm_code, c1.tm_formal_name,c2.tm_code, c2.tm_formal_name from ccdds c1, ccdds c2 where c1.tm_formal_name = c2.tm_formal_name and c1.tm_code < c2.tm_code;
exports.searchByGuess = function(guess,res) {
    console.log('category name is like: ' + guess);
    query = "select distinct tm_formal_name from ccdds where tm_formal_name like '" + guess + "%';";
    db.exec(query,(results,fields) => {
        res.json(results);
    });
};

exports.searchByCategory = function(category,res) {
    console.log('drug name is: ' + category);
    query = "select distinct health_canada_identifier,mp_formal_name,DIN_PIN as in_formulary from ccdds left join BC_drug_formulary form on ccdds.health_canada_identifier = form.DIN_PIN where ccdds.tm_formal_name = '" + category + "';";
    console.log(query);
    db.exec(query,(results,fields) => {
        console.log(results);
        var prioritized_arr = [],unprioritized_arr = [] ;
        results.forEach((result) => {
            if(result.in_formulary) {
                prioritized_arr.push(result);
            } else {
                unprioritized_arr.push(result);
            }
        });
        res.json(prioritized_arr.concat(unprioritized_arr));
    })
};

exports.searchByName = function(name,res) {
    console.log('drug name is: ' + name);
    query = "select distinct health_canada_identifier,mp_formal_name,DIN_PIN as in_formulary from ccdds left join BC_drug_formulary form on ccdds.health_canada_identifier = form.DIN_PIN where ccdds.tm_formal_name like '" + name + "%';";
    console.log(query);
    db.exec(query,(results,fields) => {
        console.log(results);
        var prioritized_arr = [],unprioritized_arr = [] ;
        results.forEach((result) => {
            if(result.in_formulary) {
                result.in_formulary = 1;
                prioritized_arr.push(result);
            } else {
                result.in_formulary = 0;
                unprioritized_arr.push(result);
            }
        });
        res.json(prioritized_arr.concat(unprioritized_arr));
    })
};