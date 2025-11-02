<template>
  <div class="p-6">
    <h1 class="text-2xl font-bold mb-4">Service Report</h1>
    <p>Select filters below to view reports by category, day, week, or month.</p>

    <div class="mt-4 flex gap-2">
      <button @click="loadReport('day')" class="bg-blue-600 text-white px-4 py-2 rounded">
        Daily Report
      </button>
      <button @click="loadReport('week')" class="bg-green-600 text-white px-4 py-2 rounded">
        Weekly Report
      </button>
      <button @click="loadReport('month')" class="bg-purple-600 text-white px-4 py-2 rounded">
        Monthly Report
      </button>
    </div>

    <div v-if="report.length" class="mt-6">
      <h2 class="text-xl font-semibold mb-2">Report Data</h2>
      <table class="min-w-full bg-white border border-gray-300">
        <thead>
          <tr class="bg-gray-100">
            <th class="py-2 px-4 border-b">Unit</th>
            <th class="py-2 px-4 border-b">Service Category</th>
            <th class="py-2 px-4 border-b">Service Name</th>
            <th class="py-2 px-4 border-b">Instances</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(item, index) in report" :key="index">
            <td class="py-2 px-4 border-b">{{ item.unit_id }}</td>
            <td class="py-2 px-4 border-b">{{ item.service_category }}</td>
            <td class="py-2 px-4 border-b">{{ item.service_name }}</td>
            <td class="py-2 px-4 border-b">{{ item.total_instances }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const report = ref([])

function loadReport(type) {
  console.log(`Loading ${type} report...`)
  // Placeholder example data — replace with backend fetch later
  report.value = [
    { unit_id: 'MMSVA01', service_category: 'Food & Beverages', service_name: 'Breakfast', total_instances: 30 },
    { unit_id: 'MMSVA02', service_category: 'CARE (Laundry)', service_name: 'Standard Wash', total_instances: 25 },
  ]
}
</script>

<style scoped>
table {
  border-collapse: collapse;
  width: 100%;
}
</style>