<!-- <docs> -->

<!-- ```vue -->
<!-- <Experiment> -->
<!--     <Screen> -->
<!--         <mazeTask -->
<!--           :targets="['The', 'kale', 'is', 'stale'.]" -->
<!--           :competitors="['Dha', 'rals', 'bo', 'tsule'.]" -->
<!--           :keys="{'f': 'left', 'j' : 'right'}" -->
<!--           :response-times.sync="$magpie.measurements.times" /> -->
<!--     </Screen> -->

<!--     <DebugResultsScreen /> -->
<!-- </Experiment> -->
<!-- ``` -->

<!-- </docs> -->


<template>
<div>
  something else
  <!-- @slot optional stimulus content -->
  <!-- <slot name="stimulus"></slot> -->
  <template v-for="(pair, i) in wordPairs">
  <KeypressInput
    :keys="keys"
    :key="i"
    :showOptions="false"
    @update:response="nextWord"
    />

    <div class="options">
        <div class="options">
          <div
            class="option"
            >
            {{ pair[0] }}
          </div>
          <div
            class="option"
            >
            {{ pair[1] }}
          </div>
        </div>
    </div>

  </template>
  <!-- @slot task content, displayed after the whole text was read -->
  <!-- <template v-if="word >= targets.length"> -->
  <!--   <Wait :time="0" @done="$emit('end')" /> -->
  <!-- </template> -->
</div>
</template>

<script>
// import KeypressInput from '../inputs/KeypressInput';
// import Wait from '../helpers/Wait';
export default {
  name: 'mazeTask',
  // components: { KeypressInput, Wait },
  props: {
    /**
     * maze-task target words
     */
    targets: {
      type: Array,
      required: true
    },
    /**
     * Array of word pairs (target, distractor)
     */
    wordPairs: {
      type: Array,
      required: true
    },
    /**
     * Give instructions on what the participant is supposed to do
     */
    instructions: {
      type: String,
      default: 'Press F for left word and J for right word.'
    },
    /**
     * The key to press to reveal the next word
     */
    keys: {
      type: Object,
      default: {'f': 'left', 'j' : 'right'}
    }
  },
  data() {
    return {
      word: -1,
      responseTimes: [],
      startTime: null,
      slide: 0
    };
  },
  methods: {
    nextSlide() {
      this.slide++;
      console.log('slide increment')
    },
    nextWord() {
      console.log('word increment')
      if (this.word > -1) {
        this.responseTimes.push(Date.now() - this.startTime);
      }
      this.word++;
      this.startTime = Date.now();
      if (this.word === this.targets.length-1) {
          console.log('final word pair reached')
        this.$emit('update:response-times', this.responseTimes);
      }
    }
  }
};
</script>

<style scoped>
.option {
  background-color: #5187ba;
  border: none;
  border-radius: 2px;
  color: white;
  cursor: pointer;
  display: inline-block;
  font-family: 'Lato', 'Noto Sans', sans-serif;
  font-size: 50px;
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
