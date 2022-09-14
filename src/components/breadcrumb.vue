<template>
  <div id="breadcrumb1" class="q-pa-md q-gutter-sm">
    <q-breadcrumbs active-color="black">
      <q-breadcrumbs-el :label="level_1_breadcrumb" icon="home" to="/" />
      <!--the first breadcrumb should point to the storage management page !-->
      <q-breadcrumbs-el :label="level_2_breadcrumb" />
    </q-breadcrumbs>
  </div>
</template>

<script>
export default {
  name: 'BreadCrumb1',
  setup() {
    return {};
  },
  props: {
    level_1_breadcrumb: {
      type: String,
    },
    level_2_breadcrumb: {
      type: String,
    },
  },
};
</script>
<style scoped>
#breadcrumb1 {
  position: absolute;
  top: 60px;
  left: 230px;
}
</style>
