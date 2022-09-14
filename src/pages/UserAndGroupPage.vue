<template>
  <BreadCrumb1
    level_1_breadcrumb="Storage Management"
    level_2_breadcrumb=" User & Group"
  ></BreadCrumb1>
  <q-btn icon="save" flat id="save_btn"> save </q-btn>
  <q-btn icon="refresh" flat id="refresh_btn"> refresh</q-btn>
  <UserAndGroupQCard1 id="qcard1"></UserAndGroupQCard1>
</template>

<script lang="ts">
import BreadCrumb1 from 'src/components/breadcrumb.vue';
import UserAndGroupQCard1 from 'src/components/user_group_qcard1.vue';
import { defineComponent } from 'vue';

export default defineComponent({
  components: { BreadCrumb1, UserAndGroupQCard1 },
  name: 'UserAndGroupPage',

  methods: {},

  data() {
    return {
      level_1_breadcrumb: '' as string,
      level_2_breadcrumb: '' as string,
    };
  },

  setup() {
    return {};
  },
});
</script>

<style scoped>
#qcard1 {
  position: absolute;
  top: 24%;
  left: 17%;
  right: 3%;
  width: 80%;
  height: 100%;
  background: #f2f2f2;
}
#save_btn {
  position: absolute;
  top: 15%;
  right: 12%;
  width: 8%;
  background-color: #00c4b3;
  color: white;
}
#refresh_btn {
  position: absolute;
  top: 15%;
  right: 3%;
  width: 8%;
  background-color: #00c4b3;
  color: white;
}
</style>
