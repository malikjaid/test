<template>
  <footer class="sticky-footer bg-white">
    <div class="container my-auto footer-container">
      <div>
        <img :src="require('@/assets/logo.png')" class="logo" />
        <div class="version">
        0.0.24
        </div>
      </div>
      <div class="copyright text-center my-auto">
        <div class="language-selector">
          <div
            v-for="(locale, index) in availableLocales"
            :key="index"
            class="language-selector__item"
            @click="selectLocale(locale)"
          >
            {{ locale }}
          </div>
        </div>
      </div>
    </div>
  </footer>
</template>


<script>
export default {
  computed: {
    availableLocales() {
      return ["en", "it"];
    }
  },

  created() {
    const localeFromCookie = this.$cookie.get("locale");
    const defaultLocale = localeFromCookie || this.$i18n.locale;
    this.selectLocale(defaultLocale);
  },

  methods: {
    selectLocale(locale) {
      this.$cookie.set("locale", locale, { expires: "30D" });
      this.$store.dispatch("roles/localLang", locale);
      this.$i18n.locale = locale;
    }
  }
};
</script>

<style scoped>
.logo {
  width: 150px;
}
.version {
  width: 15%;
  text-align: right;
}
.diaose{
  color: aliceblue;
}
</style>

<?php
$version = '2.0.82';
?>
