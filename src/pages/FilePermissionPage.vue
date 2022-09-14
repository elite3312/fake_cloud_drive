<template>
  <BreadCrumb1
    level_1_breadcrumb="Storage Management"
    level_2_breadcrumb="File Permission"
  ></BreadCrumb1>
  <div id="div-1">
    <q-icon name="create_new_folder" id="q-icon1" style="font-size: 3rem" />
    <div id="text1">Choose file/folder to set permission</div>
  </div>
  <q-btn icon="save" flat id="save_btn"> save </q-btn>
  <q-btn icon="refresh" flat id="refresh_btn"> refresh</q-btn>
  <FilePermissionQCard1 id="qcard1" />
</template>

<script lang="ts">
import BreadCrumb1 from 'src/components/breadcrumb.vue';
import { defineComponent } from 'vue';
import FilePermissionQCard1 from 'src/components/file_permission_qcard1.vue';

export default defineComponent({
  components: { BreadCrumb1, FilePermissionQCard1 },
  name: 'FilePermissionPage',

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
  height: 90%;
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
#div-1 {
  position: absolute;
  top: 18%;
  left: 20%;
  width: 80%;
}
#q-icon1 {
  color: #00c4b3;
}
#text1 {
  color: #00c4b3;
  position: absolute;
  font-size: 20px;
  top: 23%;
  left: 5%;
  width: 30%;
}
</style>
