<template>
<Experiment title="magpie3-imaze-nlms">
  
  <InstructionScreen :title="'Welcome'">
    Thank you for taking part in this experiment. 
    Your participation is voluntary. 
    You may quit any time.
    <br>
    Data collected in this experiment is completely anonymous and will be used
    for scientific purposes only.
  </InstructionScreen>

  <InstructionScreen :title="'General Instructions'"> 
    Your task is to read sentences word-by-word.
    The catch is that you will always see two candidate words on the screen.
    Only one of the two words is the one you should choose.
    The other word is a lure.
    The lure may be non-word, just nonsense like "oquitr".
    The lure may also be real English word, but an ungrammatical
    continuation of the sentence.
    In rare cases, both the correct word and the lure word could be grammatical
    continuations of the sentence, in which case you should guess the more likely
    continuation based on the sentences meaning.
    <br /> 
    <br /> 
    In sum: Your task is to always choose the correct word on the screen 
    as fast and accurately as possible.
    <br /> 
    <br />
    The experiment will take approximately 20 minutes. You can take breaks any time. 
    Please work with full focus and concentration.
    <br /> 
    <br />
    We will start with a few practice trials.
    <br /> 
    <br />
    Press F to select the left word, and J to select the right word on the screen.
  </InstructionScreen>

<!-- practice trials -->

  <template v-for="(trial, i) of practiceTrials">
    <mazeTask :trial="trial" :trialNR="i" :key="i" :progress="i / practiceTrials.length"/>
  </template>

<!--   <InstructionScreen :title="'Pause'"> -->
<!--     You have completed the training block. Take a break if you want. -->
<!--   </InstructionScreen> -->

<!--   <template v-for="(trial, i) of mainTrials1"> -->
<!--     <mazeTask :trial="trial" :trialNR="i" :key="i" :progress="i / mainTrials1.length"/> -->
<!--   </template> -->

<!-- <InstructionScreen :title="'Pause'"> -->
<!--     You have completed the first block. Take a break if you want. -->
<!--   </InstructionScreen> -->

<!--   <template v-for="(trial, i) of mainTrials2"> -->
<!--     <mazeTask :trial="trial" :trialNR="i" :key="i" :progress="i / mainTrials2.length"/> -->
<!--   </template> -->

    <PostTestScreen />

    <!-- While developing your experiment, using the DebugResults screen is fine,
      once you're going live, you can use the <SubmitResults> screen to automatically send your experimental data to the server. -->
     <!-- <DebugResultsScreen /> -->
    
    <SubmitResultsScreen/>

  </Experiment>
</template>




<script>

// Load data from csv files as javascript arrays with objects
import imaze_trials from '../trials/imaze-trials-full.csv';
import conditions from '../trials/conditions.csv'
import practiceTrials from '../trials/imaze-trials-practice.csv'
import fillers from '../trials/imaze-trials-fillers.csv'
import mazeTask from './mazeTask'
import _ from 'lodash';

// wrangle trial data

var makeMainTrials = function() {
  return(_.shuffle(_.map(conditions, function(c) {
  var matchingTrials = _.filter(imaze_trials, function(t) {
    return(t.condition == c.condition && t.suite == c.suite)
  })
  return(_.shuffle(matchingTrials)[0])
})))}

var mainTrials1 = makeMainTrials()
var mainTrials2 = makeMainTrials()

var responseTimes = []
var responses     = []
var startTime     = null
var targets       = []
var competitors   = []
var targetOnLeft  = []
var wordOnRight   = "Dummy"
var wordOnLeft    = "Yummy"
var nWords        = 0
var correct       = 'true'

var prepareNextTrial = function(trial){
    this.responseTimes = [];
    this.responses     = []
    this.startTime     = Date.now()
    this.targets       = trial.targets.split("|")
    this.competitors   = trial.competitors.split("|")
    this.nWords        = trial.targets.split("|").length
    this.correct       = 'true'
    this.targetOnLeft  = _.map(
        _.range(trial.targets.split("|").length),
        function(x) {return (_.random()) })
    this.wordOnLeft    = targetOnLeft[0] == 1 ? targets[0] : competitors[0]
    this.wordOnRight   = targetOnLeft[0] == 0 ? targets[0] : competitors[0]
}

var getLeftOption = function(j) {
    return (this.targetOnLeft[j] == 1 ? this.targets[j] : this.competitors[j])
}

var getRightOption = function(j) {
    return (this.targetOnLeft[j] == 0 ? this.targets[j] : this.competitors[j])
}
var checkCorrect = function(){
    console.log(this.correct)
    return (this.correct)
}
var nextWord = function(response,j) {
    // console.sole.log('response given: ' + $magpie.measurements.response)
    // console.log('word increment: ', word)
    this.responseTimes.push(Date.now() - this.startTime);
    var decodedResponse = response == 'right' ?
        this.getRightOption(j) : this.getLeftOption(j);
    this.responses.push(decodedResponse)
    if (decodedResponse != this.targets[j]) {
        console.log('wrong')
        this.$magpie.addTrialData({
            'RTs' : this.responseTimes,
            'responses' : this.responses,
            'aborted' : 'true'
        })
        this.correct = 'false'
        // $magpie.nextSlide()
    }
    if (j < this.nWords-1) {
        this.startTime = Date.now();
        this.$magpie.nextSlide()
    } else if (j === this.nWords-1) {
        console.log('final word pair reached')
        console.log('final RTs:', this.responseTimes)
        if (this.correct == 'true') {
            this.$magpie.addTrialData({
                'RTs' : this.responseTimes,
                'responses' : this.responses,
                'aborted' : 'false'
            })
        }
        this.$magpie.nextScreen()
    }
}

export default {
    name: 'App',
    components: { mazeTask },
    data() {
        return {
            mainTrials1,
            mainTrials2,
            targets,
            practiceTrials,
            fillers,
            competitors,
            targetOnLeft,
            nWords,
            wordOnLeft,
            wordOnRight,
            correct
        };
    },
    methods: {
        nextWord         : nextWord,
        prepareNextTrial : prepareNextTrial,
        getLeftOption    : getLeftOption,
        getRightOption   : getRightOption,
        checkCorrect     : checkCorrect
    }
};

</script>
