<template>
  <div class="max-w-3xl mx-auto bg-white rounded-lg shadow p-8 mt-10">
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold text-gray-800">Create Open Service Request (OSR)</h1>
      <button
        type="button"
        class="px-3 py-1.5 rounded bg-blue-50 text-blue-700 text-sm font-medium border border-blue-100"
        @click="openReports"
      >
        📊 Reports
      </button>
    </div>

    <p class="text-sm text-gray-600 mb-6">
      Capture only the minimum details. System will route via SDD.
    </p>

    <form class="space-y-8" @submit.prevent="handleSubmit">
      <div class="flex flex-col md:flex-row gap-4">
        <div class="flex-1">
          <label class="block mb-1 font-medium text-gray-700">Month <span class="text-red-500">*</span></label>
          <input type="month" v-model="form.request_month" class="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring focus:border-blue-400" required />
        </div>
        <div class="flex-1">
          <label class="block mb-1 font-medium text-gray-700">Unit <span class="text-red-500">*</span></label>
          <input
            type="text"
            v-model="unitSearch"
            @input="onUnitSearch"
            class="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring focus:border-blue-400 mb-2"
            placeholder="Type unit digits (e.g., 501)"
          />
          <select v-model="form.unit_id" class="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring focus:border-blue-400" required>
            <option value="" disabled>Select a unit</option>
            <option v-for="u in filteredUnits" :key="u.id" :value="u.id">{{ u.unit_name || u.unit_number || u.id }}</option>
          </select>
          <p class="mt-1 text-xs text-gray-500">Selected: {{ getUnitName(form.unit_id) || '—' }}</p>
        </div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 w-full p-4 bg-gray-50 rounded-lg border border-gray-200">
        <div>
          <label class="block mb-1 font-medium text-gray-700">Requester (Customer) <span class="text-red-500">*</span></label>
          <select v-model="form.customer_id" class="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring focus:border-blue-400" :disabled="!form.unit_id" required>
            <option v-if="!form.unit_id" disabled>Select unit first</option>
            <option v-else value="" disabled>Select Customer</option>
            <option v-for="customer in filteredCustomers" :key="customer.id" :value="customer.id">{{ customer.name || customer.full_name || customer.id }}</option>
          </select>
        </div>

        <div>
          <label class="block mb-1 font-medium text-gray-700">Whom For (Resident) <span v-if="filteredResidents.length" class="text-red-500">*</span></label>
          <select v-model="form.resident_id" multiple size="4" class="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring focus:border-blue-400" :disabled="!form.unit_id || filteredResidents.length === 0">
            <option v-for="resident in filteredResidents" :key="resident.id" :value="resident.id">{{ resident.name || resident.full_name || resident.id }}</option>
          </select>
          <p v-if="form.unit_id && filteredResidents.length === 0" class="text-xs text-gray-500 mt-1">No residents found for this unit.</p>
        </div>

        <div>
          <label class="block mb-1 font-medium text-gray-700">Payer <span class="text-red-500">*</span></label>
          <select v-model="form.payer_id" class="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring focus:border-blue-400" :disabled="!form.unit_id" required>
            <option value="" disabled>Select Payer</option>
            <option v-if="form.customer_id" :value="form.customer_id">{{ getCustomerName(form.customer_id) }} (Requester)</option>
            <option v-for="customer in otherCustomers" :key="customer.id" :value="customer.id">{{ customer.name || customer.full_name || customer.id }}</option>
          </select>
        </div>
      </div>

      <div>
        <label class="block mb-1 font-medium text-gray-700">Service Category <span class="text-red-500">*</span></label>
        <select v-model="form.service_category" class="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring focus:border-blue-400" required>
          <option value="" disabled>Select Category</option>
          <option v-for="cat in categories" :key="cat" :value="cat">{{ cat }}</option>
        </select>
      </div>

      <div v-if="form.service_category">
        <label class="block mb-1 font-medium text-gray-700">Select Services <span class="text-red-500">*</span></label>
        <div class="border border-gray-200 rounded p-4 bg-gray-50 max-h-64 overflow-y-auto">
          <div v-for="service in filteredServices" :key="service.id" class="flex items-center gap-2 py-1">
            <input type="checkbox" :id="'svc-' + service.id" :value="service.id" v-model="form.service_ids" />
            <label :for="'svc-' + service.id" class="cursor-pointer flex-1">{{ service.name || service.title || service.id }}</label>
          </div>
          <p v-if="filteredServices.length === 0" class="text-sm text-gray-500">No services in this category.</p>
        </div>
      </div>

      <div v-for="serviceId in form.service_ids" :key="serviceId" class="mt-2">
        <div class="bg-gray-50 border border-gray-200 rounded p-4">
          <details open>
            <summary class="font-semibold text-gray-800 cursor-pointer mb-2">{{ getServiceName(serviceId) }}</summary>
            <div class="space-y-4">
              <div>
                <label class="block mb-1 font-medium text-gray-700">Date Range Type <span class="text-red-500">*</span></label>
                <select v-model="serviceConfigs[serviceId].date_type" class="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring focus:border-blue-400">
                  <option value="" disabled>Select…</option>
                  <option value="Full Month">Full Month</option>
                  <option value="Date Range">Date Range</option>
                  <option value="Specific Dates">Specific Dates</option>
                </select>
              </div>

              <div v-if="serviceConfigs[serviceId].date_type === 'Date Range'" class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label class="block mb-1 font-medium text-gray-700">Start Date</label>
                  <input type="date" v-model="serviceConfigs[serviceId].start_date" class="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring focus:border-blue-400" />
                </div>
                <div>
                  <label class="block mb-1 font-medium text-gray-700">End Date</label>
                  <input type="date" v-model="serviceConfigs[serviceId].end_date" class="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring focus:border-blue-400" />
                </div>
              </div>

              <div v-if="serviceConfigs[serviceId].date_type === 'Specific Dates'">
                <label class="block mb-1 font-medium text-gray-700">Specific Dates</label>
                <input type="text" v-model="serviceConfigs[serviceId].specific_dates_input" @keydown.enter.prevent="addSpecificDate(serviceId)" placeholder="YYYY-MM-DD → Enter" class="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring focus:border-blue-400" />
                <div class="flex flex-wrap gap-2 mt-2">
                  <span v-for="(date, idx) in serviceConfigs[serviceId].specific_dates" :key="idx" class="bg-blue-100 text-blue-800 px-2 py-1 rounded flex items-center gap-1 text-sm">{{ date }} <button type="button" class="font-bold text-blue-700" @click="removeSpecificDate(serviceId, idx)">×</button></span>
                </div>
                <p v-if="specificDatesError(serviceId)" class="text-xs text-red-500 mt-1">Add at least one date.</p>
              </div>

              <div>
                <label class="block mb-1 font-medium text-gray-700">Location</label>
                <select v-model="serviceConfigs[serviceId].location" class="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring focus:border-blue-400">
                  <option value="" disabled>Select Location</option>
                  <option v-for="loc in locations" :key="loc" :value="loc">{{ loc }}</option>
                </select>
              </div>

              <div>
                <label class="block mb-1 font-medium text-gray-700">Special Instructions</label>
                <textarea v-model="serviceConfigs[serviceId].special_instructions" rows="3" class="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring focus:border-blue-400" placeholder="Enter special instructions…"></textarea>
              </div>

              <div>
                <label class="block mb-1 font-medium text-gray-700">Proof Requirement</label>
                <select v-model="serviceConfigs[serviceId].proof_type" class="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring focus:border-blue-400">
                  <option value="" disabled>Select Proof</option>
                  <option value="Photo">Photo</option>
                  <option value="Signature">Signature</option>
                  <option value="Acknowledgement">Acknowledgement</option>
                  <option value="None">None</option>
                </select>
              </div>
            </div>
          </details>
        </div>
      </div>

      <details class="bg-gray-50 border border-gray-200 rounded p-4">
        <summary class="cursor-pointer font-semibold text-gray-800">Operational Controls (for staff)</summary>
        <div class="mt-4 grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="block mb-1 font-medium text-gray-700">Service Scope</label>
            <select v-model="form.service_scope" class="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring focus:border-blue-400">
              <option value="" disabled>Select Service Scope</option>
              <option value="Unit-Level">Unit-Level</option>
              <option value="Individual-Level">Individual-Level</option>
            </select>
          </div>
          <div>
            <label class="block mb-1 font-medium text-gray-700">Payment Status</label>
            <select v-model="form.payment_status" class="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring focus:border-blue-400">
              <option value="" disabled>Select Payment Status</option>
              <option value="Prepaid">Prepaid</option>
              <option value="On Credit">On Credit</option>
              <option value="Pending">Pending</option>
              <option value="NA">NA</option>
            </select>
          </div>
        </div>
      </details>

      <div>
        <button type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-4 rounded disabled:opacity-60" :disabled="!formValid || submitting">
          {{ submitting ? 'Submitting…' : 'Create Open Request' }}
        </button>
      </div>
    </form>
  </div>
</template>

<script setup>
import { ref, reactive, computed, watch, onMounted } from 'vue'
import axios from 'axios'

const API = import.meta.env.VITE_API_BASE_URL || 'http://127.0.0.1:8000'

const form = reactive({
  request_month: '',
  unit_id: '',
  customer_id: '',
  resident_id: [],
  payer_id: '',
  service_category: '',
  service_ids: [],
  service_scope: '',
  payment_status: '',
  origin: 'OPEN'
})

const units = ref([])
const customers = ref([])
const residents = ref([])
const services = ref([])
const categories = ref([])
const locations = ref(['Unit', 'Dining Hall', 'Clinic', 'Clubhouse', 'Other'])
const submitting = ref(false)
const serviceConfigs = reactive({})

const unitSearch = ref('');
const filteredUnits = computed(() => {
  if (!unitSearch.value) return units.value;
  const q = unitSearch.value.toLowerCase();
  return units.value.filter(u => (u.unit_id || '').toLowerCase().includes(q));
});
const onUnitSearch = () => {};

const filteredCustomers = computed(() => (form.unit_id ? customers.value.filter(c => c.unit_id === form.unit_id) : []))
const filteredResidents = computed(() => (form.unit_id ? residents.value.filter(r => r.unit_id === form.unit_id) : []))
const filteredServices = computed(() => (form.service_category ? services.value.filter(s => s.category === form.service_category) : []))
const otherCustomers = computed(() => filteredCustomers.value.filter(c => c.id !== form.customer_id))

const formValid = computed(() => {
  if (!form.request_month || !form.unit_id || !form.customer_id || !form.payer_id || form.resident_id.length === 0 || form.service_ids.length === 0) return false
  for (const sid of form.service_ids) {
    const cfg = serviceConfigs[sid]
    if (!cfg || !cfg.date_type) return false
    if (cfg.date_type === 'Date Range' && (!cfg.start_date || !cfg.end_date)) return false
    if (cfg.date_type === 'Specific Dates' && (!cfg.specific_dates || cfg.specific_dates.length === 0)) return false
    if (!cfg.location) return false
  }
  return true
})

function getUnitName(id) {
  const u = units.value.find(x => x.unit_id === id || x.id === id);
  return u ? (u.unit_name || u.unit_number || u.id) : '';
}
function getCustomerName(id) {
  const c = customers.value.find(x => x.id === id)
  return c ? (c.name || c.full_name || c.id) : ''
}
function getServiceName(id) {
  const s = services.value.find(x => x.id === id)
  return s ? (s.name || s.title || s.id) : ''
}

function initServiceConfig(serviceId) {
  if (!serviceConfigs[serviceId]) {
    serviceConfigs[serviceId] = reactive({
      date_type: '',
      start_date: '',
      end_date: '',
      specific_dates: [],
      specific_dates_input: '',
      location: '',
      special_instructions: '',
      proof_type: ''
    })
  }
}

watch(() => form.service_ids.slice(), (newVal, oldVal) => {
  newVal.forEach(id => initServiceConfig(id))
  oldVal.forEach(id => {
    if (!newVal.includes(id)) delete serviceConfigs[id]
  })
})

watch(() => form.unit_id, async (newVal, oldVal) => {
  form.customer_id = '';
  form.resident_id = [];
  form.payer_id = '';
  form.service_category = '';
  form.service_ids = [];
  if (!newVal) return;
  try {
    const [custRes, resRes] = await Promise.all([
      axios.get(`${API}/customers`, { params: { unit_id: newVal } }),
      axios.get(`${API}/residents`, { params: { unit_id: newVal } })
    ]);
    customers.value = Array.isArray(custRes.data) ? custRes.data : custRes.data.customers || [];
    residents.value = Array.isArray(resRes.data) ? resRes.data : resRes.data.residents || [];
  } catch (err) {
    console.error('Failed to load customers/residents for unit', err);
  }
})

watch(() => form.customer_id, newVal => {
  if (newVal) {
    const ok = filteredCustomers.value.find(c => c.id === form.payer_id)
    if (!ok) form.payer_id = newVal
  } else form.payer_id = ''
})

function addSpecificDate(serviceId) {
  const cfg = serviceConfigs[serviceId]
  if (!cfg) return
  const d = (cfg.specific_dates_input || '').trim()
  if (!d) return
  if (!/^\d{4}-\d{2}-\d{2}$/.test(d)) {
    alert('Use YYYY-MM-DD format')
    return
  }
  if (!cfg.specific_dates.includes(d)) cfg.specific_dates.push(d)
  cfg.specific_dates_input = ''
}

function removeSpecificDate(serviceId, idx) {
  const cfg = serviceConfigs[serviceId]
  if (!cfg) return
  cfg.specific_dates.splice(idx, 1)
}

function specificDatesError(serviceId) {
  const cfg = serviceConfigs[serviceId]
  if (!cfg) return false
  return cfg.date_type === 'Specific Dates' && (!cfg.specific_dates || cfg.specific_dates.length === 0)
}

async function fetchUnits() {
  try {
    const { data } = await axios.get(`${API}/units`)
    units.value = Array.isArray(data) ? data : []
  } catch {
    units.value = []
  }
}
async function fetchCustomers() {
  try {
    const { data } = await axios.get(`${API}/customers`)
    customers.value = Array.isArray(data) ? data : []
  } catch {
    customers.value = []
  }
}
async function fetchResidents() {
  try {
    const { data } = await axios.get(`${API}/residents`)
    residents.value = Array.isArray(data) ? data : []
  } catch {
    residents.value = []
  }
}
async function fetchServices() {
  try {
    const { data } = await axios.get(`${API}/services`)
    services.value = Array.isArray(data) ? data : []
    categories.value = Array.from(new Set(services.value.map(s => s.category).filter(Boolean)))
  } catch {
    services.value = []
    categories.value = []
  }
}

onMounted(() => {
  fetchUnits()
  fetchCustomers()
  fetchResidents()
  fetchServices()
})

async function handleSubmit() {
  if (!formValid.value) return
  submitting.value = true
  try {
    const payload = {
      month: form.request_month,
      unit_id: form.unit_id,
      customer_id: form.customer_id,
      payer_id: form.payer_id,
      residents: form.resident_id,
      services: form.service_ids.map(sid => {
        const cfg = serviceConfigs[sid]
        return {
          service_id: sid,
          date_type: cfg.date_type,
          start_date: cfg.date_type === 'Date Range' ? cfg.start_date : null,
          end_date: cfg.date_type === 'Date Range' ? cfg.end_date : null,
          specific_dates: cfg.date_type === 'Specific Dates' ? cfg.specific_dates : null,
          location: cfg.location,
          special_instructions: cfg.special_instructions || '',
          proof_type: cfg.proof_type || null
        }
      }),
      service_scope: form.service_scope || null,
      payment_status: form.payment_status || null,
      origin: 'OPEN',
      status: 'New'
    }
    await axios.post(`${API}/service_delivery_log`, payload)
    alert('Open Service Request Created Successfully')
    form.request_month = ''
    form.unit_id = ''
    form.customer_id = ''
    form.resident_id = []
    form.payer_id = ''
    form.service_category = ''
    form.service_ids = []
    form.service_scope = ''
    form.payment_status = ''
    for (const key in serviceConfigs) {
      delete serviceConfigs[key]
    }
  } catch (e) {
    alert('Failed to submit Open Service Request. Please try again.')
  } finally {
    submitting.value = false
  }
}

function openReports() {
  window.open('/reports', '_blank')
}
</script>