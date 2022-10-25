<template>
  <q-card rounded horizontal class="bg-white-9">
    <!--left half-->

    <q-card id="left-half">
      <q-tabs
        ><q-tab
          label="file1"
          @click="
            remove_row_focus(current_row_focus_index);
            file_clicked('/f1', 'file1');
          " />
        <q-tab
          label="file2"
          @click="
            remove_row_focus(current_row_focus_index);
            file_clicked('/f2', 'file2');
          " />
        <q-tab
          label="file3"
          @click="
            remove_row_focus(current_row_focus_index);
            file_clicked('/f3', 'file3');
          " />
        <q-tab
          label="file4"
          @click="
            remove_row_focus(current_row_focus_index);
            file_clicked('/f4', 'file4');
          "
      /></q-tabs>
      <!--debug information-->
      <div v-if="debug_flag" class="q-mt-md">
        file index:{{ current_file_focus_index }} <br />rows:{{
          list_of_files[current_file_focus_index].permissions
        }}<br />
        inherited:{{ inherited_checkbox }}, owner:{{ owner_checkbox }}, read:{{
          read_checkbox
        }}, write:{{ write_checkbox }}<br />
        list of files: {{ list_of_files }} current_row_focus_index:
        {{ current_row_focus_index }}
        list of chips: {{ list_of_chips }}
      </div>
    </q-card>

    <!--right half-->

    <q-card id="right-half">
      <q-dialog v-model="add_prompt" persistent>
        <q-card style="width: 500px; min-height: 300px">
          <q-card-section>
            <div class="text-h6">Select groups or users to add</div>
          </q-card-section>
          <q-card-section class="q-pt-none">
            <q-input
              dense
              v-model="search_field"
              debounce="1000"
              :placeholder="$t('search')"
              @change="filter_user_and_group"
            />
          </q-card-section>
          <q-card-section horizontal>
            <!--list of users-->
            <q-table
              style="height: 200px; width: 250px"
              :rows-per-page-options="[0]"
              :rows="list_of_users"
              :columns="user_columns"
              row-key="name"
              hide-bottom
              hide-header
              bordered
              flat
            >
              <template v-slot:body="props">
                <q-tr v-if="props.row.show" :props="props">
                  <q-td key="name" :props="props">
                    <q-btn
                      flat
                      @click="
                        add_user_to_list_of_chips(props.row.name, props.row.id)
                      "
                      :label="props.row.name"
                      no-caps
                    >
                    </q-btn>
                  </q-td>
                </q-tr>
              </template>
            </q-table>
            <!--list of groups-->
            <q-table
              style="height: 200px; width: 250px"
              :rows-per-page-options="[0]"
              :rows="list_of_groups"
              :columns="group_columns"
              row-key="name"
              hide-bottom
              hide-header
              bordered
              flat
            >
              <template v-slot:body="props">
                <q-tr v-if="props.row.show" :props="props">
                  <q-td key="name" :props="props">
                    <q-btn
                      flat
                      @click="
                        add_group_to_list_of_chips(props.row.name, props.row.id)
                      "
                      :label="props.row.name"
                      no-caps
                    >
                    </q-btn>
                  </q-td>
                </q-tr>
              </template>
            </q-table>
          </q-card-section>
          <q-card-section>
            <div
              style="background: primary"
              v-if="user_or_group_already_included"
            >
              Already included!
            </div>

            <q-chip
              v-for="chip in list_of_chips"
              v-bind:key="chip.id"
              :label="chip.name + '(' + chip.type + ')'"
              removable
              @remove="remove_chip_from_list(chip.id)"
              color="primary"
              text-color="white"
            >
            </q-chip>
          </q-card-section>
          <q-card-actions align="right" class="text-primary">
            <q-btn
              flat
              label="Cancel"
              v-close-popup
              @click="
                list_of_chips = [];
                user_or_group_already_included = false;
              "
            />
            <q-btn
              flat
              label="confirm"
              @click="add_new_users_or_groups_to_permissions"
            />
          </q-card-actions>
        </q-card>
      </q-dialog>
      <!--top title and btn-->
      <q-card-section id="select-group-or-user" horizontal>
        <div class="text-h5" id="title-1">Group or User names</div>
        <q-btn
          v-if="current_file_focus_index >= 1"
          padding="xs"
          outline
          id="add-btn"
          label="Add"
          @click="add_prompt = true"
        />

        <q-btn v-else padding="xs" outline id="add-btn" label="Add" disable />
      </q-card-section>
      <q-card-section>
        <q-table
          style="height: 200px"
          :rows="list_of_files[current_file_focus_index].permissions"
          :columns="columns"
          row-key="id"
          :rows-per-page-options="[0]"
          hide-bottom
          hide-header
          bordered
          flat
        >
          <template v-slot:body="props">
            <q-tr
              v-if="props.row.show && props.row.displayMode == row_state.init"
              :props="props"
            >
              <!--q-dialog is put here, to not mess with other components-->
              <q-dialog v-model="confirm_delete" persistent>
                <q-card>
                  <q-card-section class="row items-center">
                    <q-avatar
                      icon="priority_high"
                      color="primary"
                      text-color="white"
                    />
                    <span class="q-ml-sm"
                      >Are sure you want to delete "{{
                        get_name_by_id(id_of_user_or_group_to_delete)
                      }}"?<br />This operation cannot be undone, <br />unless
                      you click refresh before save.
                    </span>
                  </q-card-section>

                  <q-card-actions align="right">
                    <q-btn flat label="Cancel" color="primary" v-close-popup />
                    <q-btn
                      flat
                      label="Confirm"
                      color="primary"
                      @click="
                        delete_user_or_group(id_of_user_or_group_to_delete)
                      "
                    />
                  </q-card-actions>
                </q-card>
              </q-dialog>
              <q-td key="id" :props="props">
                <q-icon
                  id="icon1"
                  v-if="props.row.type == 'group'"
                  name="groups"
                ></q-icon>
                <q-icon id="icon1" v-else name="person" />
              </q-td>
              <q-td key="id" :props="props">
                <q-btn
                  @click="give_row_focus(props.row.id)"
                  id="row-btn"
                  flat
                  :label="props.row.name"
                  no-caps
                >
                </q-btn>
              </q-td>
              <q-td key="id" :props="props">
                <q-btn
                  icon="delete"
                  flat
                  style="color: dark"
                  @click="
                    confirm_delete = true;
                    id_of_user_or_group_to_delete = props.row.id;
                  "
                />
              </q-td>
            </q-tr>
            <q-tr
              v-else-if="
                props.row.show && props.row.displayMode == row_state.focused
              "
              :props="props"
              style="background: #00c4b3"
            >
              <q-td key="id" :props="props">
                <q-icon
                  id="icon1"
                  v-if="props.row.type == 'group'"
                  name="groups"
                  style="color: white"
                ></q-icon>
                <q-icon id="icon1" v-else name="person" style="color: white" />
              </q-td>
              <q-td key="id" :props="props">
                <q-btn
                  id="row-btn"
                  style="color: white"
                  flat
                  @click="remove_row_focus(current_row_focus_index)"
                  :label="props.row.name"
                  no-caps
                >
                </q-btn>
              </q-td>
              <q-td key="id" :props="props">
                <q-btn disable icon="delete" flat style="color: white" />
              </q-td>
            </q-tr>
          </template> </q-table
      ></q-card-section>
      <!--Permission-->
      <q-card-section id="Permissions" horizontal>
        <div class="text-h5" id="title-1">Permissions</div>
      </q-card-section>
      <q-separator id="seperator1" />
      <q-card-section id="checkboxes">
        <div class="q-gutter-sm">
          <q-checkbox
            v-model="inherited_checkbox"
            :value="permissions.inherited"
            label="Inherited (default)"
          />
        </div>
        <div class="q-gutter-sm">
          <q-checkbox
            v-model="owner_checkbox"
            :value="permissions.owner"
            label="owner"
          />
        </div>
        <div class="q-gutter-sm">
          <q-checkbox
            v-model="read_checkbox"
            :value="permissions.read"
            label="read"
          />
        </div>
        <div class="q-gutter-sm">
          <q-checkbox
            v-model="write_checkbox"
            :value="permissions.write"
            label="write"
          /></div
      ></q-card-section>
    </q-card>
  </q-card>
</template>

<script lang="ts">
import { ref } from 'vue';
//dummy

import { defineComponent } from 'vue';
export default defineComponent({
  name: 'FilePermissionQCard1',
  components: {},
  data() {
    const columns = [
      {
        name: 'userOrGroup',
        required: true,
        label: 'Type',
        align: 'left',
        sortable: false,
      },

      {
        name: 'name',
        required: true,
        label: 'Name',
        align: 'left',
        sortable: false,
      },

      {
        name: 'remove',
        required: true,
        label: 'Remove',
        align: 'left',
        sortable: false,
      },
      {
        name: 'id',
        required: true,
        label: '',
        align: 'left',
        sortable: false,
      },
    ];
    const user_columns = [{ name: 'name', label: 'name', align: 'left' }];
    const group_columns = [{ name: 'name', label: 'name', align: 'left' }];
    const row_state = Object.freeze({
      init: 1,
      focused: 2,
    });
    const system_user_and_group = Object.freeze({
      rods: 'rods',
      rodsAdmin: 'rodsadmin',
    });
    const permissions = Object.freeze({
      inherited: 1,
      owner: 2,
      read: 3,
      write: 4,
    });
    class user {
      id: string;
      name: string;
      show = true;
      constructor(id: string, name: string) {
        this.id = id;
        this.name = name;
      }
    }
    class group {
      id: string;
      name: string;
      show = true;
      constructor(id: string, name: string) {
        this.id = id;
        this.name = name;
      }
    }
    let list_of_users: Array<user> = [];
    let list_of_groups: Array<group> = [];
    class chip {
      name: string;
      id: string; //uid,gid
      type: string; //user or group
      constructor(name: string, id: string, type: string) {
        this.name = name;
        this.id = id;
        this.type = type;
      }
    }
    let list_of_chips: Array<chip> = [];
    class user_or_group_row {
      name: string;
      type = 'user';
      id = '';
      displayMode = row_state.init;
      inherited = true;
      owner = false;
      read = false;
      write = false;
      show = true;
      constructor(
        name: string,
        id: string,
        type: string,
        inherited: boolean,
        owner: boolean,
        read: boolean,
        write: boolean
      ) {
        this.id = id;
        this.name = name;
        this.type = type;
        this.inherited = inherited;
        this.owner = owner;
        this.read = read;
        this.write = write;
      }
    }

    class file {
      name: string;
      path: string;
      permissions: Array<user_or_group_row> = [];
      constructor(name: string, path: string) {
        this.name = name;
        this.path = path;
      }
    }
    let list_of_files: Array<file> = [];
    let f = new file('', '');
    list_of_files.push(f);
    let gid = 1,
      uid = 1;
    function get_file_permissions(permissions: Array<user_or_group_row>) {
      /*get file permissions for a single file, edits a permissions array by reference*/
      //fp001
      let g = new user_or_group_row(
        'group' + gid.toString(),
        'g' + gid.toString(),
        'group',
        true,
        true,
        false,
        false
      );
      permissions.push(g);
      let u = new user_or_group_row(
        'user' + uid.toString(),
        'u' + uid.toString(),
        'user',
        true,
        false,
        false,
        false
      );
      permissions.push(u);
      uid++;
      gid++;
    }
    function get_list_of_user_and_group() {
      //dummy
      for (var i = 0; i < 5; i++) {
        list_of_users.push(new user('u' + i.toString(), 'user' + i.toString()));
        list_of_groups.push(
          new group('g' + i.toString(), 'group' + i.toString())
        );
      }
    }
    get_list_of_user_and_group();
    return {
      user_columns, //columns for users in 'add'
      user_or_group_row,
      group_columns, //columns for groups in 'add'
      chip,
      list_of_chips, //a collection of chips that work as a shopping cart when adding user or groups
      user,
      group,
      list_of_users,
      list_of_groups,
      get_file_permissions,
      system_user_and_group,
      file,
      list_of_files,
      current_file_focus_index: 0, //an integer that points to the file in focus in list_of_files
      search_field: ref(''), //input field for search box
      columns,
      permissions, //enum for all 4 types of permissions
      id_of_user_or_group_to_delete: '', //used for deleting rows
      current_row_focus_index: -1,
      row_state, //enum for 2 states that a row can be in
      debug_flag: false,
      confirm_delete: ref(false), //v model to control delete confirmation dialogue
      add_prompt: ref(false), //v model to control add dialogue
      user_or_group_already_included: false, //v model to control a waring message in add dialogue
    };
  },
  setup() {
    const inherited_checkbox = ref(false);
    const owner_checkbox = ref(false);
    const read_checkbox = ref(false);
    const write_checkbox = ref(false);
    return {
      inherited_checkbox,
      owner_checkbox,
      read_checkbox,
      write_checkbox,
    };
  },
  methods: {
    get_chip_by_id(id: string) {
      for (var i = 0; i < this.list_of_chips.length; i++) {
        if (this.list_of_chips[i].id == id) return this.list_of_chips[i];
      }
      return false;
    },
    remove_chip_from_list(id: string) {
      //delete one item from list of chips
      for (var i = 0; i < this.list_of_chips.length; i++) {
        if (this.list_of_chips[i].id == id) {
          this.list_of_chips.splice(i, 1);
          return;
        }
      }
    },
    filter_user_and_group() {
      //filters users and groups in 'add' dialogue
      if (this.search_field == '') {
        this.list_of_users.forEach((item) => {
          item.show = true;
        });

        this.list_of_groups.forEach((item) => {
          item.show = true;
        });
        return;
      }
      this.list_of_users.forEach((item) => {
        if (
          item.name.toLowerCase().search(this.search_field.toLowerCase()) == -1
        ) {
          item.show = false;
        } else {
          item.show = true;
        }
      });

      for (var i = 0; i < this.list_of_groups.length; i++) {}
      this.list_of_groups.forEach((item) => {
        if (
          item.name.toLowerCase().search(this.search_field.toLowerCase()) == -1
        ) {
          item.show = false;
        } else {
          item.show = true;
        }
      });
    },
    get_row_by_id(id: string) {
      for (var i = 0; i < this.get_rows().length; i++) {
        if (this.get_rows()[i].id == id) {
          return this.get_rows()[i];
        }
      }
      return false;
    },
    add_user_to_list_of_chips(name: string, id: string) {
      this.user_or_group_already_included = false;
      if (this.get_chip_by_id(id)) return;
      if (this.get_row_by_id(id)) {
        this.user_or_group_already_included = true;
        return;
      }

      this.list_of_chips.push(new this.chip(name, id, 'user'));
      this.user_or_group_already_included = false;
    },
    add_group_to_list_of_chips(name: string, id: string) {
      this.user_or_group_already_included = false;
      if (this.get_chip_by_id(id)) return;
      if (this.get_row_by_id(id)) {
        this.user_or_group_already_included = true;
        return;
      }
      this.list_of_chips.push(new this.chip(name, id, 'group'));
      this.user_or_group_already_included = false;
    },
    add_new_users_or_groups_to_permissions() {
      for (var i = 0; i < this.list_of_chips.length; i++) {}
      this.list_of_chips.forEach((item) => {
        var name = item.name;
        var id = item.id;
        var type = item.type;
        this.get_rows().push(
          new this.user_or_group_row(name, id, type, true, false, false, false)
        );
      });
      this.list_of_chips = [];
      this.add_prompt = false;
    },
    get_rows() {
      return this.list_of_files[this.current_file_focus_index].permissions;
    },
    get_name_by_id(id: string) {
      for (var i = 0; i < this.get_rows().length; i++) {
        if (this.get_rows()[i].id == id) {
          return this.get_rows()[i].name;
        }
      }

      return '';
    },

    write_to_back_end() {
      //fp002
    },
    delete_user_or_group(id: string) {
      this.remove_row_focus(this.current_row_focus_index);

      for (var i = 0; i < this.get_rows().length; i++) {
        if (this.get_rows()[i].id == id) {
          this.get_rows().splice(i, 1); //delete item
          break;
        }
      }
      this.inherited_checkbox = false;
      this.owner_checkbox = false;
      this.read_checkbox = false;
      this.write_checkbox = false;
      this.confirm_delete =
        false; /*this line closes the dialog window. Because sometimes when we rerender before the dialog closes itself,
      the dialog will not close correctly*/
    },

    give_row_focus(id: string) {
      if (this.current_row_focus_index != -1) {
        this.remove_row_focus(this.current_row_focus_index);
      }

      var focus_index = -1;
      for (var i = 0; i < this.get_rows().length; i++) {
        if (id == this.get_rows()[i].id) {
          this.current_row_focus_index = i;
          this.get_rows()[i].displayMode = this.row_state.focused;
          focus_index = i;
          break;
        }
      }

      //update checkboxes
      this.inherited_checkbox = this.get_rows()[focus_index].inherited;
      this.owner_checkbox = this.get_rows()[focus_index].owner;
      this.read_checkbox = this.get_rows()[focus_index].read;
      this.write_checkbox = this.get_rows()[focus_index].write;
    },
    remove_row_focus(index: number) {
      if (index == -1) return;
      this.save_edits(index);
      this.get_rows()[index].displayMode = this.row_state.init;
      this.inherited_checkbox = false;
      this.owner_checkbox = false;
      this.read_checkbox = false;
      this.write_checkbox = false;
      this.current_row_focus_index = -1;
    },
    save_edits(index: number) {
      this.get_rows()[index].inherited = this.inherited_checkbox;
      this.get_rows()[index].owner = this.owner_checkbox;
      this.get_rows()[index].read = this.read_checkbox;
      this.get_rows()[index].write = this.write_checkbox;
    },
    file_clicked(path: string, name: string) {
      for (var i = 0; i < this.list_of_files.length; i++) {
        if (path == this.list_of_files[i].path) {
          this.current_file_focus_index = i;
          return;
        }
      }
      //if list of files does not have a file that matches param path, add a file to the list of files
      let f = new this.file(name, path);
      this.get_file_permissions(f.permissions); //fp001
      this.list_of_files.push(f);
      this.current_file_focus_index = this.list_of_files.length - 1;
    },
  },
});
</script>
<style scoped>
#left-half {
  background: white;

  position: absolute;
  left: 3%;
  width: 550px;
  height: 550px;
  top: 20px;
}
#right-half {
  background: white;
  position: absolute;
  right: 3%;
  top: 20px;
  width: 550px;
  height: 550px;
}
#select-group-or-user {
  width: 550px;
  height: 45px;
}

#title-1 {
  position: absolute;
  font-size: 20px;
  top: 30%;
  left: 5%;
}

#add-btn {
  position: absolute;
  top: 30%;
  right: 9%;
  width: 80px;
  height: 40px;

  color: #00c4b3;
}
#icon1 {
  font-size: 1.8em;
  color: dark;
}
#check-box {
  color: #00c4b3;
}
#row-btn {
  color: dark;
}
#seperator1 {
  position: relative;
  top: -5%;
}
#Permissions {
  position: relative;
  top: 3%;
  width: 550px;
  height: 45px;
}
#checkboxes {
  position: relative;
  top: 0%;
}
</style>
