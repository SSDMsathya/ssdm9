import { createRouter, createWebHistory } from 'vue-router'
import Home from '../pages/Home.vue'
import OpenServiceRequestForm from '../components/forms/OpenServiceRequestForm.vue'

const routes = [
  { path: '/', component: Home },
  { path: '/service-report', component: () => import('../pages/ServiceReport.vue') },
  { path: '/open-service-request', component: OpenServiceRequestForm },
  { path: '/subscription/add', component: () => import('../components/SubscriptionForm.vue') },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router