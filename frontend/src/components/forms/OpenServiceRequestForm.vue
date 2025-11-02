<template>
  <div class="min-h-screen bg-gray-50 py-10">
    <div class="max-w-6xl mx-auto bg-white rounded-lg shadow p-8 space-y-8">
      <h1 class="text-3xl font-bold text-gray-800 border-b pb-3">Open Service Request</h1>

      <!-- Unit Selection -->
      <div>
        <label class="block mb-1 text-sm font-medium text-gray-700">Unit *</label>
        <select
          v-model="form.unit_id"
          class="border border-gray-300 rounded w-full px-4 py-2 focus:outline-none focus:ring focus:border-blue-400"
          @change="loadCustomers"
        >
          <option value="" disabled>Select Unit</option>
          <option v-for="unit in units" :key="unit.unit_id" :value="unit.unit_id">
            {{ unit.unit_id }} — {{ unit.unit_name }}
          </option>
        </select>
      </div>

      <!-- 3-column grid: Requester | Whom For | Payer -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
        <!-- Requester -->
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Requester *</label>
          <select
            v-model="form.customer_id"
            class="border border-gray-300 rounded w-full px-4 py-2 focus:outline-none focus:ring focus:border-blue-400"
            :disabled="!form.unit_id"
          >
            <option value="" disabled>Select Requester</option>
            <option
              v-for="customer in customers"
              :key="customer.customer_id"
              :value="customer.customer_id"
            >
              {{ customer.full_name }}
            </option>
            <option value="external">External Person</option>
            <option value="other_resident">Other Resident (from same unit)</option>
          </select>

          <div v-if="form.customer_id === 'external'" class="mt-2">
            <input
              type="text"
              v-model="form.external_requester_name"
              placeholder="Enter external requester name"
              class="border border-gray-300 rounded w-full px-4 py-2 focus:outline-none focus:ring focus:border-blue-400"
            />
          </div>
        </div>

        <!-- Whom For -->
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Whom For (Resident)</label>
          <select
            v-model="form.resident_ids"
            multiple
            class="border border-gray-300 rounded w-full px-4 py-2 h-28 focus:outline-none focus:ring focus:border-blue-400 overflow-y-auto"
            :disabled="!form.unit_id || customers.length === 0"
          >
            <option
              v-for="resident in customers"
              :key="resident.customer_id"
              :value="resident.customer_id"
            >
              {{ resident.full_name }}
            </option>
          </select>
          <p v-if="form.unit_id && customers.length === 0" class="text-red-600 text-sm mt-2">
            No residents found for this unit.
          </p>
        </div>

        <!-- Payer -->
        <div>
          <label class="block mb-1 text-sm font-medium text-gray-700">Payer *</label>
          <select
            v-model="form.payer_id"
            class="border border-gray-300 rounded w-full px-4 py-2 focus:outline-none focus:ring focus:border-blue-400"
            :disabled="!form.unit_id"
          >
            <option value="" disabled>Select Payer</option>
            <option
              v-for="customer in customers"
              :key="customer.customer_id"
              :value="customer.customer_id"
            >
              {{ customer.full_name }}
            </option>
            <option value="external_payer">External Payer</option>
          </select>

          <div v-if="form.payer_id === 'external_payer'" class="mt-2">
            <input
              type="text"
              v-model="form.external_payer_name"
              placeholder="Enter external payer name"
              class="border border-gray-300 rounded w-full px-4 py-2 focus:outline-none focus:ring focus:border-blue-400"
            />
          </div>
        </div>
      </div>

      <!-- Service Category -->
      <div>
        <label class="block mb-1 text-sm font-medium text-gray-700">Service Category</label>
        <select
          v-model="form.service_category"
          class="border border-gray-300 rounded w-full px-4 py-2 focus:outline-none focus:ring focus:border-blue-400"
        >
          <option value="" disabled>Select Category</option>
          <option v-for="cat in serviceCategories" :key="cat" :value="cat">
            {{ cat }}
          </option>
        </select>
      </div>

      <!-- Special Instructions -->
      <div>
        <label class="block mb-1 text-sm font-medium text-gray-700">Special Instructions</label>
        <textarea
          v-model="form.special_instructions"
          class="border border-gray-300 rounded w-full px-4 py-2 focus:outline-none focus:ring focus:border-blue-400"
          placeholder="Add notes or delivery instructions"
          rows="3"
        ></textarea>
      </div>

      <!-- Submit Button -->
      <div class="flex justify-end pt-4 border-t">
        <button
          class="bg-blue-600 text-white px-6 py-2 rounded hover:bg-blue-700 transition"
          @click="submitForm"
        >
          Submit Request
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted, watch, nextTick } from 'vue'
import axios from 'axios'

const API = 'http://127.0.0.1:8000'

const form = reactive({
  unit_id: '',
  customer_id: '',
  resident_ids: [],
  payer_id: '',
  service_category: '',
  special_instructions: '',
  external_requester_name: '',
  external_payer_name: ''
})

const units = ref([])
const customers = ref([])
const serviceCategories = [
  'Food & Beverages',
  'CARE (Housekeeping)',
  'CARE (Laundry)',
  'CARE (Health & Wellbeing)',
  'Nursing & Medical',
  'Accommodation Services',
  'Concierge On Request Services'
]

const loadUnits = async () => {
  try {
    const { data } = await axios.get(`${API}/units`)
    units.value = Array.isArray(data) ? data : data.units || []
  } catch (err) {
    console.error('Failed to load units:', err)
  }
}

const loadCustomers = async () => {
  if (!form.unit_id) return
  try {
    const { data } = await axios.get(`${API}/customers/${form.unit_id}`)
    customers.value = Array.isArray(data) ? data : data.customers || []
  } catch (err) {
    console.error('Failed to load customers:', err)
  }
}

watch(
  () => form.customer_id,
  async (newVal) => {
    if (!newVal) return

    // Handle external requester
    if (newVal === 'external') {
      form.resident_ids = []
      form.payer_id = ''
      await nextTick()
    }
    // Handle other resident case
    else if (newVal === 'other_resident') {
      form.resident_ids = []
      form.payer_id = ''
      await nextTick()
      // keep fields empty so user can manually select in the "Whom For" and "Payer"
    }
    // Default case (internal resident)
    else {
      const numericId = Number(newVal)
      form.resident_ids = [numericId]
      form.payer_id = numericId
    }
  }
)

const submitForm = async () => {
  try {
    const payload = {
      origin: 'OPEN',
      unit_id: form.unit_id,
      customer_id: form.customer_id === 'external' ? null : form.customer_id,
      external_requester_name: form.external_requester_name || null,
      resident_ids: form.resident_ids,
      payer_id: form.payer_id === 'external_payer' ? null : form.payer_id,
      external_payer_name: form.external_payer_name || null,
      service_category: form.service_category,
      special_instructions: form.special_instructions,
      created_by: 'userabc'
    }

    console.log('Submitting OSR payload:', payload)
    await axios.post(`${API}/open-requests`, payload, {
      headers: { 'Content-Type': 'application/json' }
    })
    alert('Open Service Request submitted successfully!')
  } catch (err) {
    console.error('Submission failed:', err)
    alert('Failed to submit: ' + (err.response?.data?.detail || err.message))
  }
}

onMounted(loadUnits)
</script>