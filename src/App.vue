<template>
<Experiment title="magpie3-imaze-nlms">
  <!-- <InstructionScreen :title="'Welcome'">
    This is a sample introduction screen.
  </InstructionScreen> -->

  <!-- <InstructionScreen :title="'General Instructions'"> -->
    <!--   This is a sample instructions view. -->
    <!--   <br /> -->
    <!--   <br /> -->
    <!--   First you will go through two practice trials. The practice trial view -->
    <!--   uses magpie's forced choice trial input. -->
    <!-- </InstructionScreen> -->


  <!-- <template v-for="(screen, i) of [1,2,3,4]"> -->

  <!--   <Screen :key="'screen'+i"> -->
  <!--     <Slide> -->
  <!--       <KeypressInput -->
  <!--         :keys="{' ': 'continue'}" -->
  <!--         :showOptions="false" -->
  <!--         @update:response="$magpie.nextSlide();" -->
  <!--         /> -->
  <!--       Starting slide. -->
  <!--       Press Space to continue. -->
  <!--     </Slide> -->

  <!--     <template v-for="(slide, j) of [1,2,3,4]"> -->

  <!--       <Slide :key="'slide'+j"> -->
  <!--         <KeypressInput -->
  <!--           :keys="{' ': 'continue'}" -->
  <!--           :showOptions="false" -->
  <!--           @update:response="slide >= 2 ? $magpie.nextScreen() : $magpie.nextSlide();" -->
  <!--           /> -->
  <!--         Slide {{slide}} of Screen {{screen}}. -->
  <!--         Press Space to continue. -->
  <!--       </Slide> -->

  <!--     </template> -->

  <!--   </Screen> -->
  <!-- </template> -->

<!-- practice trials -->



<!-- main trials -->


  <template v-for="(trial, i) of mainTrials1">

    <Screen 
      :key="'trial_'+ i"
      :progress="i / mainTrials1.length"
    >

      <Slide>
          <KeypressInput
            :keys="{' ': 'continue'}"
            :showOptions="false"
            @update:response="prepareNextTrial(trial);$magpie.nextSlide();"
            />
        Press Space to start the next trial.
      </Slide>

      <template v-for="(target, j) of trial.targets.split('|')">

        <Slide :key="'word_' + j">

          <template v-if=" correct == 'true' ">
          <KeypressInput
            :keys="{'f': 'left', 'j' : 'right'}"
            :showOptions="false"
            :response.sync="$magpie.measurements.response"
            @update:response="nextWord($magpie.measurements.response,j)"
            />

            <div class="options">
              <div
                class="option"
                >
                {{ getLeftOption(j) }}
              </div>
              <div
                class="option"
                >
                {{ getRightOption(j) }}
              </div>
            </div>

          </template>

          <template v-if=" correct == 'false' ">
            <KeypressInput
            :keys="{' ': 'continue'}"
            :showOptions="false"
            :response.sync="$magpie.measurements.response"
            @update:response="$magpie.nextScreen()"
            />
            Ops! That was not correct. Press Space to continue.
          </template>
        </Slide>

      </template>

    </Screen>

  </template>


  <InstructionScreen :title="'Welcome'">
    You have completed the first block. Take a break if you want.
  </InstructionScreen>


  <!--

      Comment this in, to try out interactive components like the Chat component.

      <ConnectInteractiveScreen />

      <Screen>
          <Chat :messages.sync="$magpie.measurements.messages"></Chat>
          <button @click="$magpie.saveAndNextScreen()">Next</button>
      </Screen>

      -->

    <PostTestScreen />

    <!-- While developing your experiment, using the DebugResults screen is fine,
      once you're going live, you can use the <SubmitResults> screen to automatically send your experimental data to the server. -->
     <DebugResultsScreen />
  </Experiment>
</template>


<style scoped>
.option {
  background-color: #5187ba;
  border: none;
  border-radius: 2px;
  color: white;
  cursor: pointer;
  display: inline-block;
  font-family: 'Lato', 'Noto Sans', sans-serif;
  font-size: 40px;
  line-height: 40px;
  font-weight: 700;
  letter-spacing: 0.9px;
  margin: 0 70px 70px 70px;
  outline: none;
  padding: 5px 10px;
  text-transform: uppercase;
}
.option:hover {
  background-color: #324d93;
}
</style>


<script>

// Load data from csv files as javascript arrays with objects
import imaze_trials from '../trials/imaze-trials-full.csv';
import conditions from '../trials/conditions.csv'
import practiceTrials from '../trials/imaze-trials-practice.csv'
import fillers from '../trials/imaze-trials-fillers.csv'
import mazeTask from './mazeTask.vue'
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
