<template>
  <q-card rounded horizontal class="bg-white-9">
    <!--q-dialog is put here, to not mess with other components-->
    <q-dialog v-model="add_prompt_user" persistent>
      <q-card style="min-width: 350px">
        <q-card-section v-if="!bad_user_name">
          <div class="text-h6">Input user name</div>
        </q-card-section>
        <q-card-section v-else>
          <div class="text-h6">Invalid user name</div>
        </q-card-section>
        <q-card-section class="q-pt-none">
          <q-input
            dense
            v-model="input_name"
            autofocus
            @keyup.enter="add_user(input_name)"
          />
        </q-card-section>

        <q-card-actions align="right" class="text-primary">
          <q-btn
            flat
            label="Cancel"
            v-close-popup
            @click="bad_user_name = false"
          />
          <q-btn flat label="Add user" @click="add_user(input_name)" />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!--left half-->
    <q-card-section id="left-half">
      <q-card-sections
        ><!--top title and btn-->
        <q-card-section id="q-card-section" horizontal>
          <q-icon id="icon1" name="person_outline" size="xl" />
          <div class="text-h5" id="title-1">User</div>

          <q-btn
            padding="xs"
            bordered
            flat
            id="add-btn"
            label="Add"
            @click="add_prompt_user = true"
          >
          </q-btn>
        </q-card-section>
        <q-separator />
        <q-card-section>
          <div>
            <q-input
              v-model="search_user"
              id="search-field"
              debounce="1000"
              :placeholder="$t('search')"
              @change="filter_user"
            >
              <template v-slot:append> <q-icon name="search" /> </template
            ></q-input>
          </div>

          <!--list of users-->
          <q-table
            style="height: 400px"
            :rows-per-page-options="[0]"
            :rows="list_of_users"
            :columns="columns_user"
            row-key="name_user"
            hide-bottom
            hide-header
            bordered
            flat
            v-if="left_table"
          >
            <template v-slot:body="props">
              <q-tr
                v-if="
                  props.row.show && props.row.display_mode == row_state.init
                "
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
                          user_or_group_to_delete
                        }}"?<br />This operation cannot be undone, <br />unless
                        you click refresh before save.
                      </span>
                    </q-card-section>

                    <q-card-actions align="right">
                      <q-btn
                        flat
                        label="Cancel"
                        color="primary"
                        v-close-popup
                      />
                      <q-btn
                        flat
                        label="Confirm"
                        color="primary"
                        @click="delete_user_or_group(user_or_group_to_delete)"
                      />
                    </q-card-actions>
                  </q-card>
                </q-dialog>
                <q-td key="check_user" :props="props"
                  ><q-checkbox disable v-model="dummy_false" />
                </q-td>
                <q-td key="name_user" :props="props">
                  <q-btn
                    flat
                    @click="give_focus_to_user_row(props.row.name)"
                    id="row-btn"
                    :label="props.row.name"
                    no-caps
                  >
                  </q-btn>
                </q-td>
                <q-td key="delete_user" :props="props">
                  <q-btn
                    flat
                    v-if="!props.row.removable"
                    disable
                    icon="delete"
                  />
                  <q-btn
                    flat
                    v-else
                    icon="delete"
                    @click="
                      confirm_delete = true;
                      user_or_group_to_delete = props.row.name;
                    "
                  />
                </q-td>
              </q-tr>
              <q-tr
                v-else-if="
                  props.row.show && props.row.display_mode == row_state.focused
                "
                :props="props"
                style="background: #00c4b3"
              >
                <q-td key="check_user" :props="props"
                  ><q-checkbox disable />
                </q-td>
                <q-td key="name_user" :props="props">
                  <q-btn
                    flat
                    @click="
                      remove_focus_from_user_row(current_user_in_focus_index)
                    "
                    style="color: white"
                    id="row-btn"
                    :label="props.row.name"
                    no-caps
                  >
                  </q-btn>
                </q-td>
                <q-td key="delete_user" :props="props">
                  <q-btn flat disable icon="delete" style="color: white" />
                </q-td> </q-tr
              ><q-tr
                v-if="
                  props.row.show && props.row.display_mode == row_state.editing
                "
                :props="props"
              >
                <q-td key="check_user" :props="props"
                  ><q-checkbox
                    v-if="
                      current_not_removable_users_in_focus.includes(
                        props.row.name
                      )
                    "
                    v-model="dummy_true"
                    disable
                  />
                  <q-checkbox
                    v-else
                    v-model="user_selection"
                    :val="props.row.name"
                    id="check-box"
                  />
                </q-td>
                <q-td key="name_user" :props="props">
                  <q-btn
                    flat
                    @click="give_focus_to_user_row(props.row.name)"
                    id="row-btn"
                    :label="props.row.name"
                    no-caps
                  >
                  </q-btn>
                </q-td>
                <q-td key="delete_user" :props="props">
                  <q-btn flat disable icon="delete" />
                </q-td>
              </q-tr>
              <q-tr v-else />
            </template>
          </q-table>
          <q-spinner-gears v-else color="primary" size="5em" :thickness="10" />
        </q-card-section>
      </q-card-sections>
    </q-card-section>
    <!--right half-->
    <q-card-section id="right-half">
      <!--top title and btn-->
      <q-card-section id="q-card-section" horizontal>
        <q-icon name="people_outline" id="icon1" size="xl" />

        <div class="text-h5" id="title-1">Group</div>

        <q-btn
          padding="xs"
          bordered
          flat
          id="add-btn1"
          label="Add"
          @click="add_prompt_group = true"
        >
        </q-btn>
      </q-card-section>
      <q-separator />

      <q-card-section id="table"
        ><!--another dialog for adding groups-->
        <q-dialog v-model="add_prompt_group" persistent>
          <q-card style="min-width: 350px">
            <q-card-section v-if="!bad_group_name">
              <div class="text-h6">Input group name</div>
            </q-card-section>
            <q-card-section v-else>
              <div class="text-h6">Invalid group name</div>
            </q-card-section>
            <q-card-section class="q-pt-none">
              <q-input
                dense
                v-model="input_name"
                autofocus
                @keyup.enter="add_group(input_name)"
              />
            </q-card-section>

            <q-card-actions align="right" class="text-primary">
              <q-btn
                flat
                label="Cancel"
                v-close-popup
                @click="bad_group_name = false"
              />
              <q-btn flat label="Add group" @click="add_group(input_name)" />
            </q-card-actions>
          </q-card>
        </q-dialog>
        <div>
          <q-input
            v-model="search_group"
            id="search-field"
            debounce="1000"
            :placeholder="$t('search')"
            @change="filter_group"
          >
            <template v-slot:append> <q-icon name="search" /> </template
          ></q-input>
        </div>

        <!--list of groups-->
        <q-table
          style="height: 400px"
          :rows-per-page-options="[0]"
          :rows="list_of_groups"
          :columns="columns_group"
          row-key="name_group"
          hide-bottom
          hide-header
          bordered
          flat
          v-if="right_table"
        >
          <template v-slot:body="props">
            <q-tr
              :props="props"
              v-if="props.row.show && props.row.display_mode == row_state.init"
            >
              <q-td key="check_group" :props="props">
                <q-checkbox disable v-model="dummy_false" />
              </q-td>
              <q-td key="name_group" :props="props">
                <q-btn
                  flat
                  @click="give_focus_to_group_row(props.row.name)"
                  id="row-btn"
                  :label="props.row.name"
                  no-caps
                ></q-btn>
              </q-td>
              <q-td key="delete_group" :props="props">
                <q-btn flat v-if="!props.row.removable" disable icon="delete" />
                <q-btn
                  flat
                  v-else
                  icon="delete"
                  @click="
                    confirm_delete = true;
                    user_or_group_to_delete = props.row.name;
                  "
                />
              </q-td>
            </q-tr>
            <q-tr
              v-else-if="
                props.row.show && props.row.display_mode == row_state.focused
              "
              :props="props"
              style="background: #00c4b3"
            >
              <q-td key="check_group" :props="props">
                <q-checkbox disable />
              </q-td>
              <q-td key="name_group" :props="props">
                <q-btn
                  flat
                  @click="
                    remove_focus_from_group_row(current_group_in_focus_index)
                  "
                  style="color: white"
                  id="row-btn"
                  :label="props.row.name"
                  no-caps
                >
                </q-btn>
              </q-td>
              <q-td key="delete_group" :props="props">
                <q-btn flat disable icon="delete" style="color: white" />
              </q-td>
            </q-tr>
            <q-tr
              :props="props"
              v-else-if="
                props.row.show && props.row.display_mode == row_state.editing
              "
            >
              <q-td key="check_group" :props="props">
                <q-checkbox
                  v-if="
                    props.row.not_removable_users.includes(
                      current_user_in_focus
                    )
                  "
                  v-model="dummy_true"
                  disable
                />
                <q-checkbox
                  v-else
                  v-model="group_selection"
                  :val="props.row.name"
                  id="check-box"
                />
              </q-td>
              <q-td key="name_group" :props="props">
                <q-btn
                  flat
                  @click="give_focus_to_group_row(props.row.name)"
                  id="row-btn"
                  :label="props.row.name"
                  no-caps
                >
                </q-btn>
              </q-td>
              <q-td key="delete_group" :props="props">
                <q-btn flat disable icon="delete" />
              </q-td>
            </q-tr>
          </template>
        </q-table>

        <q-spinner-gears v-else color="primary" size="5em" :thickness="10" />

        <!--debug information-->
        <div v-if="debug_flag" class="q-mt-md">
          actions: {{ list_of_actions }}
          <br />
          list_of_users: {{ list_of_users }} <br /><br />
          list_of_groups: {{ list_of_groups }} <br />
        </div>
      </q-card-section>
    </q-card-section>
  </q-card>
</template>

<script lang="ts">
import { ref } from 'vue';

import { defineComponent } from 'vue';
export default defineComponent({
  name: 'UserAndGroupQCard1',
  components: {},
  data() {
    const columns_user = [
      {
        name: 'check_user',
        required: true,
        label: 'check',
        align: 'left',
        // eslint-disable-next-line @typescript-eslint/no-unsafe-return
        field: (row: { checked: boolean }) => row.checked,
        // eslint-disable-next-line @typescript-eslint/restrict-template-expressions
        format: (val: user_row) => `${val}`,
        sortable: false,
      },

      {
        name: 'name_user',
        required: true,
        label: 'name',
        align: 'left',
        // eslint-disable-next-line @typescript-eslint/no-unsafe-return
        field: (row: { name: string }) => row.name,
        // eslint-disable-next-line @typescript-eslint/restrict-template-expressions
        format: (val: user_row) => `${val}`,
        sortable: true,
      },
      {
        name: 'delete_user',
        required: true,
        label: 'delete',
        align: 'left',
        sortable: false,
      },
    ];

    const columns_group = [
      {
        name: 'check_group',
        required: true,
        label: 'check',
        align: 'left',
        // eslint-disable-next-line @typescript-eslint/no-unsafe-return
        field: (row: { checked: boolean }) => row.checked,
        // eslint-disable-next-line @typescript-eslint/restrict-template-expressions
        format: (val: group_row) => `${val}`,
        sortable: false,
      },

      {
        name: 'name_group',
        required: true,
        label: 'name',
        align: 'left',
        // eslint-disable-next-line @typescript-eslint/no-unsafe-return
        field: (row: { name: string }) => row.name,
        // eslint-disable-next-line @typescript-eslint/restrict-template-expressions
        format: (val: group_row) => `${val}`,
        sortable: true,
      },
      {
        name: 'delete_group',
        required: true,
        label: 'delete',
        align: 'left',
        sortable: false,
      },
    ];
    const row_state = Object.freeze({
      init: 1,
      focused: 2,
      editing: 3,
    });

    class user_row {
      name: string;
      uid = '';
      display_mode = row_state.init;
      show = true;
      removable = true;
      has_called_backend = false;
      constructor(name: string, removable = true) {
        this.name = name;
        this.removable = removable;
        this.uid = name;
      }
    }
    class group_row {
      name: string;
      gid = '';
      display_mode = row_state.init;
      show = true;
      removable = true;
      users: Array<string> = [];
      not_removable_users: Array<string> = [];

      has_called_backend = false; //flag for whether or not we should call api that fills users
      constructor(name: string, removable = true) {
        this.name = name;
        this.removable = removable;
        this.gid = name;
      }
    }
    const action_type = Object.freeze({
      user_add: 'user_add',
      user_delete: 'user_delete',
      group_add: 'group_add',
      group_delete: 'group_delete',
    });

    class action {
      //to store user add/delete,group add/delete

      action_type: string;
      target: string; //username,groupname
      constructor(action_type: string, target: string) {
        this.action_type = action_type;
        this.target = target;
      }
    }
    let list_of_users: Array<user_row> = [];
    let list_of_groups: Array<group_row> = [];
    let list_of_actions: Array<action> = []; //list of ug 003~006 actions
    function getDummyData() {
      //ug001
      list_of_users.push(new user_row('rods', false));
      list_of_users.push(new user_row('henry'));
      //ug002
      list_of_groups.push(new group_row('group1', true));
      list_of_groups.push(new group_row('group2', false));
      list_of_groups.push(new group_row('group3', true));
    }
    getDummyData();
    return {
      left_table: ref(true),
      right_table: ref(true),
      action,
      action_type,
      list_of_actions,
      group_row,
      user_row,
      row_state,
      columns_user,
      columns_group,
      list_of_users,
      list_of_groups,
      user_or_group_to_delete: '',
      search_user: ref(''),
      search_group: ref(''),
      dummy_false: ref(false),
      dummy_true: ref(true),
      confirm_delete: ref(false), //v model to control delete confirmation dialogue
      add_prompt_user: ref(false), //v model to control add user or group dialogue
      add_prompt_group: ref(false),
      input_name: ref(''), //v ref to receive user input of name to add
      bad_user_name: false,
      bad_group_name: false,
      debug_flag: true,
      current_not_removable_users_in_focus: [] as Array<string>,
      current_user_in_focus: '' as string,
      current_user_in_focus_index: -1,
      current_group_in_focus_index: -1,
    };
  },
  setup() {
    const user_selection = ref([]); //empty, initially nobody is selected
    const group_selection = ref([]);
    return { user_selection, group_selection };
  },
  methods: {
    get_index_of_user_row(user_name: string) {
      for (var i = 0; i < this.list_of_users.length; i++) {
        if (user_name == this.list_of_users[i].name) return i;
      }
      return -1;
    },
    get_index_of_group_row(group_name: string) {
      for (var i = 0; i < this.list_of_groups.length; i++) {
        if (group_name == this.list_of_groups[i].name) return i;
      }
      return -1;
    },
    get_user_row_by_name(user_name: string) {
      for (var i = 0; i < this.list_of_users.length; i++) {
        if (user_name == this.list_of_users[i].name)
          return this.list_of_users[i];
      }
      return this.list_of_users[0];
    },
    get_group_row_by_name(group_name: string) {
      for (var i = 0; i < this.list_of_groups.length; i++) {
        if (group_name == this.list_of_groups[i].name)
          return this.list_of_groups[i];
      }
      return this.list_of_groups[0];
    },
    get_users_under_group(
      group_name: string,
      user_array: Array<string>,
      non_removable_users: Array<string>
    ) {
      //ug008
      switch (group_name) {
        case 'group1':
          user_array.push('henry');
          non_removable_users.push('henry');
          break;
        case 'group2':
          user_array.push('rods');
          break;
        case 'group3':
          user_array.push('rods');
      }
    },
    call_backend_for_group_row_by_index(group_index: number) {
      if (this.list_of_groups[group_index].has_called_backend) return;
      this.get_users_under_group(
        this.list_of_groups[group_index].name,
        this.list_of_groups[group_index].users,
        this.list_of_groups[group_index].not_removable_users
      );
      this.list_of_groups[group_index].has_called_backend = true;
    },
    call_backend_for_group_row(group_item: {
      name: string;
      gid: string;
      display_mode: number;
      show: boolean;
      removable: boolean;
      users: string[];
      not_removable_users: string[];
      has_called_backend: boolean;
    }) {
      if (group_item.has_called_backend) return;
      this.get_users_under_group(
        group_item.name,
        group_item.users,
        group_item.not_removable_users
      );
      group_item.has_called_backend = true;
    },
    call_backend_for_user_row_by_index(user_index: number) {
      if (this.list_of_users[user_index].has_called_backend) return;
      this.get_groups_user_belongs_to(this.list_of_users[user_index].name);
      this.list_of_groups[user_index].has_called_backend = true;
    },
    call_backend_for_user_row(user_row: {
      name: string;
      uid: string;
      display_mode: number;
      show: boolean;
      removable: boolean;
      has_called_backend: boolean;
    }) {
      if (user_row.has_called_backend) return;
      this.get_groups_user_belongs_to(user_row.name);
      user_row.has_called_backend = true;
    },

    get_groups_user_belongs_to(user_name: string) {
      //ug007
      let group_array: Array<string> = [];
      switch (user_name) {
        case 'henry':
          group_array.push('group1');
          break;
        case 'rods':
          group_array.push('group2');
          group_array.push('group3');
          break;
      }

      this.list_of_groups.every((item) => {
        const index = group_array.indexOf(item.name);
        if (index > -1) {
          // alert(group_array);
          this.call_backend_for_group_row_by_index(
            this.get_index_of_group_row(item.name)
          );
          group_array.splice(index, 1);
        }

        if (group_array == []) return false;
        return true;
      });
    },

    write_to_back_end() {
      //call ug003~006 according to this.list_of_actions
      //after this is done,
      //for each modified row in groups, call ug010
    },
    give_focus_to_user_row(userName: string) {
      //check if any other user row is focused. If theres is one, save its edit results, remove its focus
      if (this.current_user_in_focus_index != -1) {
        this.remove_focus_from_user_row(this.current_user_in_focus_index);
      }
      //check if any other group row is focused. If theres is one, save its edit results, remove its focus
      if (this.current_group_in_focus_index != -1) {
        this.remove_focus_from_group_row(this.current_group_in_focus_index);
      }

      this.right_table = false;

      //give focus to the clicked user row
      let row = this.get_user_row_by_name(userName);
      this.call_backend_for_user_row(row);
      //the row is the clicked user
      row.display_mode = this.row_state.focused; //focused
      this.current_user_in_focus_index = this.get_index_of_user_row(userName);
      this.current_user_in_focus = userName;
      this.group_selection = [];
      this.user_selection = [];

      this.list_of_groups.forEach((item) => {
        item.users.forEach((user_item) => {
          if (userName == user_item) {
            this.group_selection.push(item.name as never);
          }
        });
        item.display_mode = this.row_state.editing;
      });

      setTimeout(() => {
        this.right_table = true;
      }, 200);
    },
    remove_focus_from_user_row(index: number) {
      /*chanege display_mode for both table*/

      this.list_of_users.forEach((item) => {
        item.display_mode = this.row_state.init;
      });

      this.list_of_groups.forEach((item) => {
        item.display_mode = this.row_state.init;
      });
      this.right_table = false;
      this.save_results_of_group_table(this.list_of_users[index].name);
      this.current_user_in_focus = '';
      this.current_user_in_focus_index = -1;
      this.group_selection = [];
      setTimeout(() => {
        this.right_table = true;
      }, 200);
    },
    save_results_of_group_table(userName: string) {
      //this saves edit results of the right side table

      this.list_of_groups.forEach((item) => {
        const index = item.users.indexOf(userName);
        if (index > -1) {
          item.users.splice(index, 1); //delete our user from that group, if user is in that group
        }
      });
      //update list of groups

      this.list_of_groups.forEach((item) => {
        if (this.group_selection.includes(item.name as never)) {
          item.users.push(userName);
        }
      });
    },

    give_focus_to_group_row(groupName: string) {
      //check if any other group is focused, if there is, remove its focus, save its edit results

      if (this.current_group_in_focus_index != -1) {
        this.remove_focus_from_group_row(this.current_group_in_focus_index);
      }
      //check if any other user is focused, if there is, remove its focus, save its edit results

      if (this.current_user_in_focus_index != -1) {
        this.remove_focus_from_user_row(this.current_user_in_focus_index);
      }

      this.left_table = false;
      //give focus to selected group row
      let row = this.get_group_row_by_name(groupName);
      this.call_backend_for_group_row(row);
      this.current_not_removable_users_in_focus = row.not_removable_users;
      this.current_group_in_focus_index =
        this.get_index_of_group_row(groupName);
      row.display_mode = this.row_state.focused; //give focus to the matched group row
      this.group_selection = [];
      this.user_selection = [];
      row.users.forEach((item) => {
        this.user_selection.push(item as never);
      });
      this.list_of_users.forEach((item) => {
        item.display_mode = this.row_state.editing;
      });

      setTimeout(() => {
        this.left_table = true;
      }, 200);
    },
    remove_focus_from_group_row(index: number) {
      /*change display_mode for both table*/
      this.list_of_users.forEach((item) => {
        item.display_mode = this.row_state.init;
      });

      this.list_of_groups.forEach((item) => {
        item.display_mode = this.row_state.init;
      });
      this.left_table = false;
      this.save_results_of_user_table(this.list_of_groups[index].name);
      this.current_not_removable_users_in_focus = [];
      this.current_group_in_focus_index = -1;
      this.user_selection = [];
      setTimeout(() => {
        this.left_table = true;
      }, 200);
    },
    save_results_of_user_table(groupName: string) {
      let row = this.get_group_row_by_name(groupName);
      row.users = [];
      //first clear all users from group, we will add them back later

      //add back users according to ref userselected
      this.user_selection.forEach((item) => {
        row.users.push(item as string);
      });
    },

    filter_user() {
      if (this.search_user == '') {
        this.list_of_users.forEach((item) => {
          item.show = true;
        });
        return;
      }
      this.left_table = false;
      //actual search

      this.list_of_users.forEach((item) => {
        if (
          item.name.toLowerCase().search(this.search_user.toLowerCase()) == -1
        ) {
          item.show = false;
        } else {
          item.show = true;
        }
      });
      setTimeout(() => {
        this.left_table = true;
      }, 200);
    },
    filter_group() {
      if (this.search_group == '') {
        this.list_of_groups.forEach((item) => {
          item.show = true;
        });
        return;
      }
      this.right_table = false;
      //actual search
      this.list_of_groups.forEach((item) => {
        if (
          item.name.toLowerCase().search(this.search_group.toLowerCase()) == -1
        ) {
          item.show = false;
        } else item.show = true;
      });
      setTimeout(() => {
        this.right_table = true;
      }, 200);
    },
    delete_user_or_group(name: string) {
      //alert('delete:' + name);
      //check if its a user

      var isUser = false,
        deleteIndex = -1;
      deleteIndex = this.get_index_of_user_row(name);
      if (deleteIndex != -1) isUser = true;

      if (isUser) {
        //push into actions array
        this.list_of_actions.push(
          new this.action(this.action_type.user_delete, name)
        );
        //update list of users
        this.list_of_users[deleteIndex].show = false;

        this.list_of_users.splice(deleteIndex, 1); //delete our user
        //
        //update list group
        this.list_of_groups.forEach((item) => {
          var index = item.users.indexOf(name);
          if (index > -1) {
            item.users.splice(index, 1); //delete our user from that group, if user is in that group
          }
        });
      } else {
        //its a group to be deleted
        //push into actions array
        this.list_of_actions.push(
          new this.action(this.action_type.group_delete, name)
        );
        let index = this.get_index_of_group_row(name);
        this.list_of_groups[index].show = false;

        this.list_of_groups.splice(index, 1); //delete group from list
      }
      this.confirm_delete =
        false; /*this line closes the dialog window. Because sometimes when we rerender before the dialog closes itself,
      the dialog will not close correctly*/
    },
    check_username_validity(name: string) {
      //check
      if (name == '') return false;
      for (var i = 0; i < this.list_of_users.length; i++) {
        if (this.list_of_users[i].name == name) return false;
      }
      return true;
    },
    add_user(name: string) {
      if (this.check_username_validity(name)) {
        //push into actions array
        this.list_of_actions.push(
          new this.action(this.action_type.user_add, name)
        );
        //if a user is in focus, remove focus from user
        if (
          this.list_of_users.length >= 1 &&
          this.list_of_users[0].display_mode == this.row_state.focused
        ) {
          this.remove_focus_from_user_row(0);
        } else if (this.list_of_users.length >= 1) {
          this.give_focus_to_user_row(this.list_of_users[0].name);
          this.remove_focus_from_user_row(0);
        } //if a group is in focus, remove focus
        if (
          this.list_of_groups.length >= 1 &&
          this.list_of_groups[0].display_mode == this.row_state.focused
        ) {
          this.remove_focus_from_group_row(0);
        } else if (this.list_of_groups.length >= 1) {
          this.give_focus_to_group_row(this.list_of_groups[0].name);
          this.remove_focus_from_group_row(0);
        }
        this.bad_user_name = false;
        this.list_of_users.push(new this.user_row(name));
        this.add_prompt_user = false;
      } else this.bad_user_name = true;
    },
    check_groupname_validity(name: string) {
      //check
      if (name == '') return false;
      for (var i = 0; i < this.list_of_groups.length; i++) {
        if (this.list_of_groups[i].name == name) return false;
      }
      return true;
    },
    add_group(name: string) {
      if (this.check_groupname_validity(name)) {
        //push into actions array
        this.list_of_actions.push(
          new this.action(this.action_type.group_add, name)
        );
        //if a user is in focus, remove focus from user
        if (
          this.list_of_users.length >= 1 &&
          this.list_of_users[0].display_mode == this.row_state.focused
        ) {
          this.remove_focus_from_user_row(0);
        } else if (this.list_of_users.length >= 1) {
          this.give_focus_to_user_row(this.list_of_users[0].name);
          this.remove_focus_from_user_row(0);
        } //if a group is in focus, remove focus
        if (
          this.list_of_groups.length >= 1 &&
          this.list_of_groups[0].display_mode == this.row_state.focused
        ) {
          this.remove_focus_from_group_row(0);
        } else if (this.list_of_groups.length >= 1) {
          this.give_focus_to_group_row(this.list_of_groups[0].name);
          this.remove_focus_from_group_row(0);
        }
        this.bad_group_name = false;
        this.list_of_groups.push(new this.group_row(name));
        this.add_prompt_group = false;
      } else this.bad_group_name = true;
    },
  },
});
</script>
<style scoped>
#left-half {
  background: #f2f2f2;
  position: absolute;
  left: 3%;
  width: 550px;
  top: 0%;
}
#right-half {
  background: #f2f2f2;
  position: absolute;
  right: 3%;
  top: 0%;
  width: 550px;
}
#q-card-section {
  width: 550px;
  height: 45px;
}
#icon1 {
  color: #00c4b3;
}
#title-1 {
  padding-left: 5px;
  color: #00c4b3;
}
#add-btn {
  position: absolute;
  right: 9%;
  width: 80px;
  height: 40px;
  background: white;
  color: #00c4b3;
}
#add-btn1 {
  position: absolute;
  right: 9%;
  width: 80px;
  height: 40px;
  background: white;
  color: #00c4b3;
}
#search-field {
  width: 430px;
}
#check-box {
  color: #00c4b3;
}
#row-btn {
  width: 200px;
  height: 40px;
}
</style>
