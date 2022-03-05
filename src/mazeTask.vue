  <template>

    <Screen :progress="progress">

      <Slide>
          <KeypressInput
            :keys="{' ': 'continue'}"
            :showOptions="false"
            @update:response="prepareNextTrial(trial);$magpie.nextSlide();"
            />
        Press Space to start the next trial.
        <br>
        Remember to try to select the best next word the sequence 
        as fast and reliably as possible.
        <br>
        Press F for the left word and J for the right word on the screen.
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

<style scoped>
.option {
  background-color: #5187ba;
  border: none;
  border-radius: 2px;
  color: white;
  cursor: pointer;
  display: inline-block;
  font-family: 'Lato', 'Noto Sans', sans-serif;
  font-size: 30px;
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
import _ from 'lodash';

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
var trial         = []

var prepareNextTrial = function(trial){
    this.responseTimes = []
    this.responses     = []
    this.trial         = trial
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
          this.$magpie.addTrialData(
              Object.assign(
                this.trial, 
                { 
                  'RTs' : this.responseTimes,
                  'responses' : this.responses,
                  'aborted' : 'true'
                }
              )
            )
        this.correct = 'false'
        // $magpie.nextSlide()
    }
    if (j < this.nWords-1) {
        this.startTime = Date.now();
        this.$magpie.nextSlide()
    } else if (j === this.nWords-1) {
        if (this.correct == 'true') {
          this.$magpie.addTrialData(
              Object.assign(
                this.trial, 
                { 
                  'RTs' : this.responseTimes,
                  'responses' : this.responses,
                  'aborted' : 'false'
                }
              )
            )
        }
        this.$magpie.nextScreen()
    }
}

export default {
    name: 'mazeTask',
    props: {
        trial: {
            type: Object,
            required: true
        },
        trialNR: {
          type: Number,
          required: true
        },
        progress: {
          type: Number,
          default: undefined
        }
    },
    data() {
        return {
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

