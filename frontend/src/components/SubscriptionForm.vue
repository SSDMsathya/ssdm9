<template>
  <div class="max-w-[1100px] mx-auto p-6">
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-3xl font-semibold text-gray-800">Add Monthly Subscription</h1>
      <button class="btn-secondary" @click="openReportsDashboard" type="button">
        📊 Generate Reports
      </button>
    </div>

    <!-- Stepper -->
    <nav class="grid grid-cols-7 gap-2 mb-6">
      <button
        v-for="(lbl, idx) in stepLabels"
        :key="lbl"
        class="flex flex-col items-center py-2 rounded border text-xs"
        :class="currentStep === idx + 1 ? 'bg-blue-600 text-white border-blue-600' : 'bg-white text-gray-700 border-gray-300'"
        @click="jumpTo(idx + 1)"
        type="button"
      >
        <span>{{ lbl }}</span>
      </button>
    </nav>

    <section class="bg-white rounded-lg border shadow-sm p-5">

      <!-- STEP 1: Month -->
      <div v-if="currentStep === 1" class="space-y-4">
        <h2 class="text-xl font-medium">Step 1: Select Subscription Month</h2>
        <p class="text-gray-600">Choose current month or up to 6 months ahead. Period start/end auto-calculate.</p>

        <select v-model="form.month" class="input w-full">
          <option disabled value="">Select month…</option>
          <option v-for="m in monthOptions" :key="m.value" :value="m.value">
            {{ m.label }}
          </option>
        </select>

        <div class="flex justify-end">
          <button class="btn-primary" @click="nextFromMonth">Next</button>
        </div>
      </div>

      <!-- STEP 2: Unit & Customers (merged inline, spreadsheet style) -->
      <div v-if="currentStep === 2" class="space-y-4">
        <h2 class="text-xl font-medium">Step 2: Select Unit and Customers</h2>
        <p class="text-gray-600">
          Type to search (e.g., last 3–4 digits). Pick the unit and then select customers for this monthly subscription.
        </p>

        <div class="mb-2">
          <label class="label">Search Unit</label>
          <input
            v-model="unitSearch"
            placeholder="Type unit digits, e.g., 501"
            class="input w-full"
            type="text"
            @input="onUnitSearch"
          />
        </div>

        <div v-if="!form.unit_id" class="mb-2">
          <label class="label">Unit</label>
          <div class="overflow-x-auto">
            <table class="min-w-full border text-sm spreadsheet-table">
              <thead class="bg-gray-50">
                <tr>
                  <th class="border px-2 py-1 text-sm">Unit</th>
                  <th class="border px-2 py-1 text-sm">Select</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="u in filteredUnits" :key="u.unit_id">
                  <td class="border px-2 py-1">
                    {{ u.unit_id }} — {{ u.unit_name || u.unit_id }}
                  </td>
                  <td class="border px-2 py-1 text-center">
                    <button
                      class="btn-primary px-2 py-1 text-xs"
                      @click="form.unit_id = u.unit_id"
                      type="button"
                    >
                      Select
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <div v-else>
          <div class="mb-2 flex flex-col sm:flex-row sm:items-center gap-2">
            <div>
              <label class="label">Unit</label>
              <div class="font-semibold text-gray-800">
                {{ form.unit_id }}
                <span v-if="currUnitObj && currUnitObj.unit_name" class="text-gray-500 ml-2">({{ currUnitObj.unit_name }})</span>
              </div>
            </div>
            <button
              class="btn-secondary text-xs ml-0 sm:ml-4"
              type="button"
              @click="form.unit_id = ''; customers = []; selectedCustomers = []"
            >
              Change Unit
            </button>
          </div>
          <div v-if="customers.length === 0" class="text-red-600">No customers found for this unit.</div>
          <div v-else>
            <div class="mb-2 text-gray-700 font-semibold">Select Customers (1–4)</div>
            <div class="overflow-x-auto">
              <table class="min-w-full border text-xs spreadsheet-table">
                <thead class="bg-gray-50">
                  <tr>
                    <th class="border px-2 py-1">Unit</th>
                    <th class="border px-2 py-1">Customer Name</th>
                    <th class="border px-2 py-1">Relationship</th>
                    <th class="border px-2 py-1">Customer ID</th>
                    <th class="border px-2 py-1">Select</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="c in customers" :key="c.customer_id">
                    <td class="border px-2 py-1">
                      {{ form.unit_id }}
                      <span v-if="currUnitObj && currUnitObj.unit_name" class="text-gray-500">({{ currUnitObj.unit_name }})</span>
                    </td>
                    <td class="border px-2 py-1">{{ c.full_name }}</td>
                    <td class="border px-2 py-1">
                      <input
                        type="text"
                        v-model="c.relationship"
                        class="border px-2 py-1 text-xs rounded w-full"
                        placeholder="Relationship"
                      />
                    </td>
                    <td class="border px-2 py-1">{{ c.customer_id }}</td>
                    <td class="border px-2 py-1 text-center">
                      <input
                        type="checkbox"
                        :value="c"
                        v-model="selectedCustomers"
                        class="w-4 h-4"
                        :disabled="!isSelected(c.customer_id) && selectedCustomers.length >= 4"
                      />
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div class="flex items-center justify-between mt-2">
              <button class="btn-secondary" @click="prev">Back</button>
              <div class="text-sm text-gray-500">Selected: {{ selectedCustomers.length }}/4</div>
              <button class="btn-primary" @click="confirmCustomers">Next</button>
            </div>
          </div>
        </div>
      </div>

      <!-- STEP 4 + 5 per Customer: Categories & Services -->
      <div v-if="currentStep === 4" class="space-y-5">
        <div class="flex items-center justify-between">
          <h2 class="text-xl font-medium">
            Step 4 & 5: Configure Services → <span class="text-blue-700">{{ activeCustomer?.full_name }}</span>
          </h2>
          <div class="text-sm text-gray-600">
            Customer {{ activeCustomerIndex + 1 }} of {{ selectedCustomers.length }}
          </div>
        </div>

        <!-- Category selection (expand) -->
        <div class="space-y-2">
          <h3 class="font-semibold text-gray-800">Service Categories</h3>
          <div class="w-full mt-3">
            <div class="grid grid-cols-2 sm:grid-cols-2 lg:grid-cols-3 gap-4">
              <label
                v-for="cat in filteredCategoryOrder"
                :key="cat"
                class="flex items-center space-x-2 p-2 border rounded hover:bg-gray-50"
              >
                <input
                  type="checkbox"
                  class="w-4 h-4"
                  :checked="isCategorySelectedForActive(cat)"
                  @change="toggleCategoryForActive(cat, $event.target.checked)"
                />
                <span class="text-sm font-medium text-gray-700">{{ cat }}</span>
              </label>
            </div>
          </div>
        </div>

        <!-- Services under selected categories (spreadsheet-style table) -->
        <div class="space-y-6">
          <div
            v-for="cat in categoryOrder"
            :key="cat + '-panel'"
            v-show="isCategorySelectedForActive(cat)"
            class="border rounded-lg"
          >
            <div class="px-3 py-2 bg-gray-100 rounded-t-lg font-semibold">{{ cat }}</div>
            <div class="p-3">
              <div class="overflow-x-auto">
                <table class="w-full text-xs border-collapse">
                  <thead class="bg-gray-50">
                    <tr>
                      <th class="border px-2 py-1">Select</th>
                      <th class="border px-2 py-1">Service</th>
                      <th class="border px-2 py-1">Scope</th>
                      <th class="border px-2 py-1">Start</th>
                      <th class="border px-2 py-1">End</th>
                      <th class="border px-2 py-1">Dates</th>
                      <th class="border px-2 py-1">Time</th>
                      <th class="border px-2 py-1">Location</th>
                      <th class="border px-2 py-1">Proof</th>
                      <th class="border px-2 py-1">Notes</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr
                      v-for="svc in filteredServicesForActive(cat)"
                      :key="svc.service_id"
                      :class="isServiceChosenForActive(cat, svc.service_id) ? 'bg-blue-50' : ''"
                    >
                      <td class="border px-2 py-1 text-center">
                        <input
                          type="checkbox"
                          class="w-4 h-4"
                          :checked="isServiceChosenForActive(cat, svc.service_id)"
                          @change="toggleServiceForActive(cat, svc)"
                        />
                        <span v-if="isExclusiveService(svc.service_id)" class="text-[10px] bg-orange-100 text-orange-800 px-1 py-0.5 rounded ml-1" title="This service is mutually exclusive with other variants">
                          ⚠️
                        </span>
                      </td>
                      <td class="border px-2 py-1">
                        <span class="font-medium">{{ svc.service_name }}</span>
                        <span class="text-[11px] text-gray-500">({{ svc.service_id }})</span>
                      </td>
                      <td class="border px-2 py-1 text-[11px] text-gray-500">
                        {{ svc.service_scope === 'UNIT' ? 'Unit' : 'Individual' }}
                      </td>
                      <td class="border px-2 py-1">
                        <input
                          v-if="isServiceChosenForActive(cat, svc.service_id)"
                          type="date"
                          class="border rounded px-2 py-1 w-full"
                          v-model="serviceCfg(activeCustomer.customer_id, cat, svc.service_id).start_date"
                          :min="periodStart"
                          :max="periodEnd"
                        />
                      </td>
                      <td class="border px-2 py-1">
                        <input
                          v-if="isServiceChosenForActive(cat, svc.service_id)"
                          type="date"
                          class="border rounded px-2 py-1 w-full"
                          v-model="serviceCfg(activeCustomer.customer_id, cat, svc.service_id).end_date"
                          :min="periodStart"
                          :max="periodEnd"
                        />
                      </td>
                      <td class="border px-2 py-1">
                        <input
                          v-if="isServiceChosenForActive(cat, svc.service_id)"
                          type="text"
                          class="border rounded px-2 py-1 w-full"
                          v-model="serviceCfg(activeCustomer.customer_id, cat, svc.service_id).specific_dates_text"
                          placeholder="e.g. 1,4,6"
                        />
                      </td>
                      <td class="border px-2 py-1">
                        <input
                          v-if="isServiceChosenForActive(cat, svc.service_id)"
                          type="time"
                          class="border rounded px-2 py-1 w-full"
                          v-model="serviceCfg(activeCustomer.customer_id, cat, svc.service_id).time"
                        />
                      </td>
                      <td class="border px-2 py-1">
                        <select
                          v-if="isServiceChosenForActive(cat, svc.service_id)"
                          class="border rounded px-2 py-1 w-full"
                          v-model="serviceCfg(activeCustomer.customer_id, cat, svc.service_id).location"
                        >
                          <option value="" disabled>Select…</option>
                          <option v-for="loc in locationOptionsFor(svc)" :key="loc" :value="loc">
                            {{ loc }}
                          </option>
                        </select>
                      </td>
                      <td class="border px-2 py-1 text-center">
                        <input
                          v-if="isServiceChosenForActive(cat, svc.service_id)"
                          :id="'proof-'+activeCustomer.customer_id+'-'+svc.service_id"
                          type="checkbox"
                          class="w-4 h-4"
                          v-model="serviceCfg(activeCustomer.customer_id, cat, svc.service_id).proof_required"
                        />
                      </td>
                      <td class="border px-2 py-1">
                        <textarea
                          v-if="isServiceChosenForActive(cat, svc.service_id)"
                          rows="1"
                          class="border rounded px-2 py-1 w-full"
                          v-model="serviceCfg(activeCustomer.customer_id, cat, svc.service_id).special_instructions"
                        ></textarea>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>

        <!-- Exclusivity Warnings Display -->
        <div v-if="getActiveCustomerExclusivityWarnings.length > 0" class="mt-4 p-4 bg-orange-50 border border-orange-200 rounded-lg">
          <h4 class="font-semibold text-orange-800 mb-3 flex items-center">
            <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"></path>
            </svg>
            Service Selection Updates
          </h4>
          <div class="space-y-3">
            <div 
              v-for="warning in getActiveCustomerExclusivityWarnings" 
              :key="warning.timestamp"
              class="p-3 bg-white border border-orange-300 rounded-lg shadow-sm"
            >
              <div class="flex items-start justify-between">
                <div class="flex-1">
                  <p class="text-sm text-orange-800 font-medium mb-2">{{ warning.message }}</p>
                  <div class="mt-2">
                    <p class="text-xs text-orange-700 font-medium mb-1">What happened:</p>
                    <ul class="text-xs text-orange-600 list-disc list-inside space-y-1">
                      <li v-for="suggestion in warning.suggestions" :key="suggestion">
                        {{ suggestion }}
                      </li>
                    </ul>
                  </div>
                </div>
                <div class="ml-3 flex-shrink-0">
                  <span 
                    class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium"
                    :class="{
                      'bg-red-100 text-red-800': warning.type === 'resource_conflict' || warning.type === 'location_conflict',
                      'bg-orange-100 text-orange-800': warning.type === 'time_conflict' || warning.type === 'category_conflict'
                    }"
                  >
                    {{ warning.type.replace('_', ' ').toUpperCase() }}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="flex flex-wrap items-center justify-between gap-3 pt-2 border-t">
          <div class="flex gap-3">
            <button class="btn-secondary" @click="prev">Back</button>
            <button
              v-if="activeCustomerIndex > 0"
              class="btn-secondary"
              @click="copyFromPrevious"
              type="button"
              :title="'Copy from '+ selectedCustomers[activeCustomerIndex - 1]?.full_name"
            >
              Repeat previous customer
            </button>
          </div>

          <div class="flex gap-3">
            <button class="btn-primary" @click="saveCurrentCustomerAndNext">
              Save {{ activeCustomer?.full_name }} & Next
            </button>
          </div>
        </div>
      </div>

      <!-- STEP 6: Preview -->
      <div v-if="currentStep === 5" class="space-y-4">
        <h2 class="text-xl font-medium">Step 6: Preview (Expanded)</h2>
        <p class="text-gray-600">This is a generated preview of service occurrences within the selected month.</p>

        <div class="overflow-auto border rounded">
          <table class="min-w-full text-sm">
            <thead class="bg-gray-100">
              <tr>
                <th class="th">Customer</th>
                <th class="th">Service</th>
                <th class="th">Date</th>
                <th class="th">Category</th>
                <th class="th">Time</th>
                <th class="th">Location</th>
                <th class="th">Proof</th>
              </tr>
            </thead>
            <tbody>
              <template v-for="cust in selectedCustomers" :key="cust.customer_id">
                <tr class="bg-gray-100 font-semibold">
                  <td colspan="7" class="px-2 py-2">{{ cust.full_name }}</td>
                </tr>
                <tr
                  v-for="row in summarizedPreviewFor(cust.customer_id)"
                  :key="row.key"
                  class="border-t"
                >
                  <td class="td">{{ row.customer_name }}</td>
                  <td class="td">{{ row.service_name }}</td>
                  <td class="td">{{ row.date_range }}</td>
                  <td class="td">{{ row.category }}</td>
                  <td class="td">{{ row.time || '—' }}</td>
                  <td class="td">{{ row.location || '—' }}</td>
                  <td class="td">{{ row.proof_required ? 'Yes' : 'No' }}</td>
                </tr>
              </template>
            </tbody>
          </table>
        </div>

        <div class="flex justify-between">
          <button class="btn-secondary" @click="prev">Back</button>
          <button class="btn-primary" @click="goToConfirm">Next</button>
        </div>
      </div>

      <!-- STEP 7: Confirm & Save -->
      <div v-if="currentStep === 6" class="space-y-4">
        <h2 class="text-xl font-medium">Step 7: Confirm & Save</h2>
        <p class="text-gray-600">When you save, the subscription will be created as a DRAFT (user stage). Supervisor approval happens later.</p>

        <div class="rounded border p-3 bg-gray-50">
          <div><span class="font-semibold">Month:</span> {{ form.month }}</div>
          <div><span class="font-semibold">Unit:</span> {{ form.unit_id }}</div>
          <div>
            <span class="font-semibold">Customers:</span>
            <span>
              {{ selectedCustomers.map(c => c.full_name).join(', ') }}
            </span>
          </div>
          <div><span class="font-semibold">Services chosen:</span> {{ totalServiceCount }}</div>
        </div>

        <div class="flex justify-between">
          <button class="btn-secondary" @click="prev">Back</button>
          <button class="btn-primary" @click="submitAll">Save Subscription</button>
        </div>
      </div>

    </section>
  </div>
</template>

<script setup>
import { reactive, ref, computed, onMounted, watch } from 'vue'
import axios from 'axios'

// ──────────────────────────────────────────────────────────────────────────────
// API base
// ──────────────────────────────────────────────────────────────────────────────
const API = 'http://127.0.0.1:8000'

// ──────────────────────────────────────────────────────────────────────────────
// Exclusivity Rule Engine
// ──────────────────────────────────────────────────────────────────────────────
/**
 * Service Exclusivity Rules Engine
 * Prevents conflicts between mutually exclusive services within the same time period
 * Based on GPT-5's comprehensive service conflict management system
 */

// Exclusivity rule definitions
const EXCLUSIVITY_RULES = {
  // Time-based exclusivity (services that cannot overlap in time)
  TIME_EXCLUSIVE: {
    'meal_services': {
      description: 'Meal services cannot overlap',
      services: ['BREAKFAST', 'LUNCH', 'DINNER', 'SNACK'],
      conflict_type: 'time_overlap',
      buffer_minutes: 30
    },
    'medical_appointments': {
      description: 'Medical appointments cannot overlap',
      services: ['DOCTOR_VISIT', 'NURSE_CHECK', 'PHYSIOTHERAPY', 'MEDICATION_ADMIN'],
      conflict_type: 'time_overlap',
      buffer_minutes: 15
    }
  },
  
  // Category-based exclusivity (services from conflicting categories)
  CATEGORY_EXCLUSIVE: {
    'cleaning_conflicts': {
      description: 'Cleaning services cannot run simultaneously',
      categories: ['CARE (Housekeeping)', 'CARE (Laundry)'],
      conflict_type: 'category_exclusive',
      scope: 'UNIT'
    },
    'medical_conflicts': {
      description: 'Medical services cannot overlap with personal care',
      categories: ['Nursing & Medical', 'CARE (Health & Wellbeing)'],
      conflict_type: 'category_exclusive',
      scope: 'INDIVIDUAL'
    }
  },
  
  // Resource-based exclusivity (services requiring same resources)
  RESOURCE_EXCLUSIVE: {
    'transportation': {
      description: 'Transportation services cannot overlap',
      services: ['AMBULANCE', 'TAXI_SERVICE', 'SHUTTLE_BUS'],
      conflict_type: 'resource_exclusive',
      resource: 'vehicle'
    },
    'staff_conflicts': {
      description: 'Services requiring same specialized staff',
      services: ['PHYSIOTHERAPY', 'OCCUPATIONAL_THERAPY'],
      conflict_type: 'resource_exclusive',
      resource: 'therapist'
    }
  },
  
  // Location-based exclusivity (services requiring same location)
  LOCATION_EXCLUSIVE: {
    'dining_hall': {
      description: 'Dining hall services cannot overlap',
      location: 'Dining Hall',
      services: ['MEAL_SERVICE', 'SPECIAL_EVENT', 'COMMUNITY_MEETING'],
      conflict_type: 'location_exclusive'
    },
    'clinic': {
      description: 'Clinic services cannot overlap',
      location: 'Clinic',
      services: ['DOCTOR_VISIT', 'NURSE_CHECK', 'VACCINATION'],
      conflict_type: 'location_exclusive'
    }
  }
}

// Exclusivity validation functions
const ExclusivityEngine = {
  /**
   * Check for time-based conflicts between services
   */
  checkTimeConflicts(service1, service2, time1, time2) {
    if (!time1 || !time2) return false
    
    const [h1, m1] = time1.split(':').map(Number)
    const [h2, m2] = time2.split(':').map(Number)
    const minutes1 = h1 * 60 + m1
    const minutes2 = h2 * 60 + m2
    
    // Check all time-based exclusivity rules
    for (const rule of Object.values(EXCLUSIVITY_RULES.TIME_EXCLUSIVE)) {
      if (rule.services.includes(service1) && rule.services.includes(service2)) {
        const buffer = rule.buffer_minutes || 0
        return Math.abs(minutes1 - minutes2) < buffer
      }
    }
    return false
  },
  
  /**
   * Check for category-based conflicts
   */
  checkCategoryConflicts(category1, category2, scope) {
    for (const rule of Object.values(EXCLUSIVITY_RULES.CATEGORY_EXCLUSIVE)) {
      if (rule.categories.includes(category1) && rule.categories.includes(category2)) {
        if (rule.scope === 'ANY' || rule.scope === scope) {
          return true
        }
      }
    }
    return false
  },
  
  /**
   * Check for resource-based conflicts
   */
  checkResourceConflicts(service1, service2) {
    for (const rule of Object.values(EXCLUSIVITY_RULES.RESOURCE_EXCLUSIVE)) {
      if (rule.services.includes(service1) && rule.services.includes(service2)) {
        return true
      }
    }
    return false
  },
  
  /**
   * Check for location-based conflicts
   */
  checkLocationConflicts(service1, service2, location1, location2) {
    if (!location1 || !location2 || location1 !== location2) return false
    
    for (const rule of Object.values(EXCLUSIVITY_RULES.LOCATION_EXCLUSIVE)) {
      if (rule.location === location1 && 
          rule.services.includes(service1) && 
          rule.services.includes(service2)) {
        return true
      }
    }
    return false
  },
  
  /**
   * Comprehensive conflict detection
   */
  detectConflicts(serviceConfig1, serviceConfig2) {
    const conflicts = []
    
    // Time conflicts
    if (this.checkTimeConflicts(
      serviceConfig1.service_id, 
      serviceConfig2.service_id,
      serviceConfig1.time,
      serviceConfig2.time
    )) {
      conflicts.push({
        type: 'time_conflict',
        message: `Time conflict: ${serviceConfig1.service_name} and ${serviceConfig2.service_name} cannot be scheduled at the same time`
      })
    }
    
    // Category conflicts
    if (this.checkCategoryConflicts(
      serviceConfig1.category,
      serviceConfig2.category,
      serviceConfig1.service_scope
    )) {
      conflicts.push({
        type: 'category_conflict',
        message: `Category conflict: ${serviceConfig1.category} and ${serviceConfig2.category} services cannot overlap`
      })
    }
    
    // Resource conflicts
    if (this.checkResourceConflicts(
      serviceConfig1.service_id,
      serviceConfig2.service_id
    )) {
      conflicts.push({
        type: 'resource_conflict',
        message: `Resource conflict: ${serviceConfig1.service_name} and ${serviceConfig2.service_name} require the same resources`
      })
    }
    
    // Location conflicts
    if (this.checkLocationConflicts(
      serviceConfig1.service_id,
      serviceConfig2.service_id,
      serviceConfig1.location,
      serviceConfig2.location
    )) {
      conflicts.push({
        type: 'location_conflict',
        message: `Location conflict: ${serviceConfig1.service_name} and ${serviceConfig2.service_name} cannot use ${serviceConfig1.location} simultaneously`
      })
    }
    
    return conflicts
  },
  
  /**
   * Validate all services for a customer against exclusivity rules
   */
  validateCustomerServices(customerId, chosenServices) {
    const conflicts = []
    const services = []
    
    // Flatten all services for this customer
    for (const category of Object.keys(chosenServices[customerId] || {})) {
      for (const serviceId of Object.keys(chosenServices[customerId][category] || {})) {
        const config = chosenServices[customerId][category][serviceId]
        services.push({
          service_id: serviceId,
          service_name: config.service_name,
          category: category,
          service_scope: config.service_scope,
          time: config.time,
          location: config.location,
          ...config
        })
      }
    }
    
    // Check each pair of services for conflicts
    for (let i = 0; i < services.length; i++) {
      for (let j = i + 1; j < services.length; j++) {
        const serviceConflicts = this.detectConflicts(services[i], services[j])
        conflicts.push(...serviceConflicts)
      }
    }
    
    return conflicts
  },
  
  /**
   * Get conflict resolution suggestions
   */
  getResolutionSuggestions(conflict) {
    const suggestions = {
      time_conflict: [
        'Adjust the time of one service to avoid overlap',
        'Schedule services on different days',
        'Use different time slots with sufficient buffer'
      ],
      category_conflict: [
        'Schedule services from conflicting categories on different days',
        'Use different time periods for each category',
        'Consider alternative service arrangements'
      ],
      resource_conflict: [
        'Schedule services requiring same resources at different times',
        'Use alternative resources if available',
        'Coordinate with other units to avoid resource conflicts'
      ],
      location_conflict: [
        'Use different locations for conflicting services',
        'Schedule services at different times',
        'Consider alternative venues'
      ]
    }
    
    return suggestions[conflict.type] || ['Please review service scheduling to resolve conflicts']
  }
}

// Global exclusivity validation state
const exclusivityWarnings = ref([])
const exclusivityErrors = ref([])

// ──────────────────────────────────────────────────────────────────────────────
// Exclusivity Validation Functions
// ──────────────────────────────────────────────────────────────────────────────

/**
 * Handle exclusivity before adding a service
 * Automatically unticks conflicting services and displays a warning
 */
const handleExclusivity = (customerId, category, newServiceId) => {
  const cid = customerId
  const cat = category

  // Define exclusivity groups for mutually exclusive services
  const conflictGroups = [
    ['F&B204', 'F&B205', 'F&B206'], // Breakfast variants
    ['F&B207', 'F&B209', 'F&B211'], // Lunch variants
    ['F&B210', 'F&B212', 'F&B208']  // Dinner variants
  ]

  for (const group of conflictGroups) {
    if (group.includes(newServiceId)) {
      const otherIds = group.filter(id => id !== newServiceId)
      let removedServices = []
      
      for (const oid of otherIds) {
        if (chosenServices[cid]?.[cat]?.[oid]) {
          // Store the service name for the warning message
          const removedServiceName = chosenServices[cid][cat][oid].service_name || oid
          removedServices.push(removedServiceName)
          
          // Remove conflicting service
          delete chosenServices[cid][cat][oid]
        }
      }
      
      // Force Vue reactivity to update checkbox UI
      if (removedServices.length > 0) {
        // Create a new object to trigger Vue reactivity
        chosenServices[cid][cat] = { ...chosenServices[cid][cat] }
        
        // Add a visible warning
        const newServiceName = getServiceName(newServiceId) || newServiceId
        exclusivityWarnings.value.push({
          customerId: cid,
          serviceId: newServiceId,
          type: 'category_conflict',
          message: `Exclusive selection: "${newServiceName}" replaces ${removedServices.join(', ')}. Only one variant per meal type can be chosen.`,
          suggestions: ['Choose only one variant per meal type.', 'The previous selection has been automatically removed.'],
          timestamp: new Date().toISOString()
        })

        // Clear warnings for removed services
        otherIds.forEach(serviceId => {
          clearExclusivityWarnings(cid, serviceId)
        })
      }
    }
  }
}

/**
 * Helper function to get service name by ID
 */
const getServiceName = (serviceId) => {
  for (const category of Object.values(servicesByCategory.value)) {
    const service = category.find(s => s.service_id === serviceId)
    if (service) return service.service_name
  }
  return null
}

/**
 * Check if a service is part of an exclusivity group
 */
const isExclusiveService = (serviceId) => {
  const conflictGroups = [
    ['F&B204', 'F&B205', 'F&B206'], // Breakfast variants
    ['F&B207', 'F&B209', 'F&B211'], // Lunch variants
    ['F&B210', 'F&B212', 'F&B208']  // Dinner variants
  ]
  
  return conflictGroups.some(group => group.includes(serviceId))
}

/**
 * Validate service exclusivity for a specific customer and service
 */
const validateServiceExclusivity = (customerId, serviceId) => {
  // Clear existing warnings for this customer
  exclusivityWarnings.value = exclusivityWarnings.value.filter(w => w.customerId !== customerId)
  
  // Get all conflicts for this customer
  const conflicts = ExclusivityEngine.validateCustomerServices(customerId, chosenServices)
  
  // Convert conflicts to warnings
  conflicts.forEach(conflict => {
    exclusivityWarnings.value.push({
      customerId,
      serviceId,
      type: conflict.type,
      message: conflict.message,
      suggestions: ExclusivityEngine.getResolutionSuggestions(conflict),
      timestamp: new Date().toISOString()
    })
  })
}

/**
 * Clear exclusivity warnings for a specific service
 */
const clearExclusivityWarnings = (customerId, serviceId) => {
  exclusivityWarnings.value = exclusivityWarnings.value.filter(w => 
    !(w.customerId === customerId && w.serviceId === serviceId)
  )
}

/**
 * Validate all services for the active customer
 */
const validateActiveCustomerExclusivity = () => {
  const cid = activeCustomer.value?.customer_id
  if (!cid) return
  
  // Clear existing warnings for this customer
  exclusivityWarnings.value = exclusivityWarnings.value.filter(w => w.customerId !== cid)
  
  // Validate all services
  const conflicts = ExclusivityEngine.validateCustomerServices(cid, chosenServices)
  
  // Add warnings
  conflicts.forEach(conflict => {
    exclusivityWarnings.value.push({
      customerId: cid,
      serviceId: 'multiple',
      type: conflict.type,
      message: conflict.message,
      suggestions: ExclusivityEngine.getResolutionSuggestions(conflict),
      timestamp: new Date().toISOString()
    })
  })
}

/**
 * Get exclusivity warnings for the active customer
 */
const getActiveCustomerExclusivityWarnings = computed(() => {
  const cid = activeCustomer.value?.customer_id
  if (!cid) return []
  
  return exclusivityWarnings.value.filter(w => w.customerId === cid)
})

/**
 * Check if there are any blocking exclusivity errors
 */
const hasExclusivityErrors = computed(() => {
  return exclusivityWarnings.value.some(w => 
    w.type === 'resource_conflict' || w.type === 'location_conflict'
  )
})

// ──────────────────────────────────────────────────────────────────────────────
// STEP Labels
// ──────────────────────────────────────────────────────────────────────────────
const stepLabels = [
  'Month',
  'Unit',
  'Customers',
  'Configure (Per Customer)',
  'Preview',
  'Confirm & Save',
  'Confirm & Save'
]

// ──────────────────────────────────────────────────────────────────────────────
// State
// ──────────────────────────────────────────────────────────────────────────────
const currentStep = ref(1)              // 1..7 (we collapsed steps: 4&5 per customer, then 6=preview, 7=confirm -> here 5=preview, 6=confirm, 7=confirm & save)
const form = reactive({
  month: '',
  unit_id: ''
})

const units = ref([])
const unitSearch = ref('')
const customers = ref([])
const selectedCustomers = ref([])       // array of full customer objects
const activeCustomerIndex = ref(0)

const servicesRaw = ref([])             // fetched services (subscription-eligible)
const servicesByCategory = ref({})      // grouped
const categoryOrder = ref([])

/** selections per customer */
const selectedCategories = reactive({}) // { [customer_id]: Set(categoryName) }
const chosenServices = reactive({})     // { [customer_id]: { [category]: { [service_id]: configObj } } }

const previewRows = ref([])

// Phase 2: Unit isolation & scope visibility
const lastLoadedUnitId = ref('')

const resetForNewUnit = () => {
  console.log('Resetting for new unit:', form.unit_id)
  selectedCustomers.value = []
  activeCustomerIndex.value = 0
  customers.value = []
  servicesRaw.value = []
  servicesByCategory.value = {}
  for (const k of Object.keys(selectedCategories)) delete selectedCategories[k]
  for (const k of Object.keys(chosenServices)) delete chosenServices[k]
  previewRows.value = []
  // Purge UNIT-scope services from chosenServices
  for (const cid of Object.keys(chosenServices)) {
    for (const cat of Object.keys(chosenServices[cid] || {})) {
      for (const sid of Object.keys(chosenServices[cid][cat] || {})) {
        const svc = chosenServices[cid][cat][sid]
        if (svc?.service_scope === 'UNIT') delete chosenServices[cid][cat][sid]
      }
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Helpers
// ──────────────────────────────────────────────────────────────────────────────
// Months (current + 6 ahead)
const monthOptions = computed(() => {
  const out = []
  const now = new Date()
  for (let i = 0; i <= 6; i++) {
    const d = new Date(now)
    d.setMonth(d.getMonth() + i)
    const value = d.toISOString().slice(0, 7) // YYYY-MM
    const label = d.toLocaleString('default', { month: 'long', year: 'numeric' })
    out.push({ value, label })
  }
  return out
})

const periodStart = computed(() => {
  if (!form.month) return ''
  const [y, m] = form.month.split('-').map(n => parseInt(n, 10))
  return `${form.month}-01`
})
const periodEnd = computed(() => {
  if (!form.month) return ''
  const [y, m] = form.month.split('-').map(n => parseInt(n, 10))
  const last = new Date(y, m, 0).getDate()
  return `${form.month}-${String(last).padStart(2, '0')}`
})

// Searchable Units
const filteredUnits = computed(() => {
  if (!unitSearch.value) return units.value
  const q = unitSearch.value.toLowerCase()
  return units.value.filter(u => (u.unit_id || '').toLowerCase().includes(q))
})
const onUnitSearch = () => { /* no-op, computed reacts automatically */ }

const weekdays = [
  { value: 1, label: 'Mon' },
  { value: 2, label: 'Tue' },
  { value: 3, label: 'Wed' },
  { value: 4, label: 'Thu' },
  { value: 5, label: 'Fri' },
  { value: 6, label: 'Sat' },
  { value: 0, label: 'Sun' }
]

const activeCustomer = computed(() => selectedCustomers.value[activeCustomerIndex.value] || null)

// For Step 2: find the current unit object
const currUnitObj = computed(() => {
  return units.value.find(u => u.unit_id === form.unit_id)
})

// Filtered categories (only show categories that have services)
const filteredCategoryOrder = computed(() =>
  categoryOrder.value.filter(cat => (servicesByCategory.value[cat] || []).length > 0)
)

/* counts */
const totalServiceCount = computed(() => {
  let n = 0
  for (const cid of Object.keys(chosenServices)) {
    const catMap = chosenServices[cid] || {}
    for (const cat of Object.keys(catMap)) {
      n += Object.keys(catMap[cat] || {}).length
    }
  }
  return n
})

// ──────────────────────────────────────────────────────────────────────────────
// Navigation
// ──────────────────────────────────────────────────────────────────────────────
const next = () => { if (currentStep.value < 7) currentStep.value++ }
const prev = () => {
  if (currentStep.value === 4 && activeCustomerIndex.value > 0) {
    // go back across customers
    activeCustomerIndex.value--
  } else if (currentStep.value > 1) {
    currentStep.value--
  }
}
const jumpTo = (step) => {
  // Disable manual jumping — navigation only through Next/Back
  if (step === currentStep.value) return
  window.alert('Step jumping is disabled. Please use Next or Back to navigate sequentially.')
}

// ──────────────────────────────────────────────────────────────────────────────
// Step actions
// ──────────────────────────────────────────────────────────────────────────────
const nextFromMonth = () => {
  if (!form.month) return window.alert('Please select a month.')
  next()
}

const loadUnits = async () => {
  try {
    const { data } = await axios.get(`${API}/units`)
    // Expecting { units: [...] } or [ ... ]
    units.value = Array.isArray(data) ? data : (data.units || [])
  } catch (err) {
    console.error(err)
    window.alert('Failed to load units.')
  }
}

const loadCustomers = async () => {
  if (!form.unit_id) return
  // Phase 2: Check if unit changed, reset if so
  if (lastLoadedUnitId.value !== form.unit_id) {
    resetForNewUnit()
    lastLoadedUnitId.value = form.unit_id
  }
  try {
    // Prefer parameterised route; fallback retained if only query works
    let res
    try {
      res = await axios.get(`${API}/customers/${encodeURIComponent(form.unit_id)}`)
    } catch {
      res = await axios.get(`${API}/customers`, { params: { unit_id: form.unit_id } })
    }
    const data = res.data
    customers.value = Array.isArray(data) ? data : (data.customers || data || [])
  } catch (err) {
    console.error(err)
    window.alert('Failed to load customers.')
  }
}

const isSelected = (cid) => selectedCustomers.value.some(c => c.customer_id === cid)

const confirmCustomers = async () => {
  if (selectedCustomers.value.length === 0) return window.alert('Select at least one customer (max 4).')
  // Fetch subscription-eligible services ONCE
  await loadSubscriptionServices()
  // init structures for each selected
  selectedCustomers.value.forEach(c => {
    if (!selectedCategories[c.customer_id]) selectedCategories[c.customer_id] = new Set()
    if (!chosenServices[c.customer_id]) chosenServices[c.customer_id] = {}
  })
  activeCustomerIndex.value = 0
  currentStep.value = 4
}

const loadSubscriptionServices = async () => {
  if (servicesRaw.value.length) return
  try {
    const { data } = await axios.get(`${API}/services`)
    console.log("Services API raw:", data)

    // Handle both grouped and flat service list structures
    let rawServices = data.services || data
    if (Array.isArray(rawServices)) {
      const grouped = {}
      for (const s of rawServices) {
        const cat = s.service_category || 'Uncategorized'
        if (!grouped[cat]) grouped[cat] = []
        grouped[cat].push(s)
      }
      rawServices = grouped
    }

    if (!rawServices || Object.keys(rawServices).length === 0) {
      console.warn("No services found – check backend shape or filter logic")
      servicesRaw.value = []
      servicesByCategory.value = {}
      categoryOrder.value = []
      return
    }

    const list = []
    for (let [cat, items] of Object.entries(rawServices)) {
      const cleanCat = (cat || '').trim()
      for (const s of items) {
        // Include all services (temporary until backend adds open_or_subscription flag)
        const eligible = true
        if (!eligible) continue

        const codeStr = s.id ? s.id.slice(-3) : ''
        const codeNum = parseInt(codeStr)
        if (isNaN(codeNum)) {
          console.warn('Skipping uncoded service:', s)
          continue
        }

        list.push({
          service_id: s.id,
          service_name: s.name,
          service_category: cleanCat || 'Uncategorized',
          service_scope: s.service_scope || 'INDIVIDUAL',
          open_or_subscription: s.open_or_subscription || '',
          default_delivery_location: s.default_delivery_location || '',
          proof_required: !!s.proof_required,
          delivery_team: s.delivery_team || '',
          sort_code: codeNum
        })
      }
    }

    // Sort within each category by code number ascending
    const grouped = {}
    for (const s of list.sort((a, b) => a.sort_code - b.sort_code)) {
      const cat = s.service_category
      if (!grouped[cat]) grouped[cat] = []
      s._defaults = {
        start_date: periodStart.value,
        end_date: periodEnd.value,
        specific_dates_text: '',
        time: '',
        location: '',
        proof_required: false,
        special_instructions: ''
      }
      grouped[cat].push(s)
    }

    // Global category order per operational flow
    const flowOrder = [
      'Food & Beverages',
      'CARE (Housekeeping)',
      'CARE (Laundry)',
      'CARE (Health & Wellbeing)',
      'Nursing & Medical',
      'Accommodation Services',
      'Concierge On Request Services',
      'Resident Admin & Billing',
      'Estate, Legal, Death & Rituals'
    ]

    const allCats = Object.keys(grouped)
    const orderedCats = []
    for (const c of flowOrder) {
      if (allCats.includes(c)) orderedCats.push(c)
    }
    const remaining = allCats.filter(c => !flowOrder.includes(c)).sort()
    categoryOrder.value = [...orderedCats, ...remaining]

    servicesRaw.value = list
    servicesByCategory.value = grouped
    console.log("Processed services:", grouped)
  } catch (err) {
    console.error(err)
    window.alert('Failed to load services.')
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Category & service selection for ACTIVE customer
// ──────────────────────────────────────────────────────────────────────────────
const isCategorySelectedForActive = (cat) => {
  const cid = activeCustomer.value?.customer_id
  if (!cid) return false
  return selectedCategories[cid]?.has(cat) || false
}
const toggleCategoryForActive = (cat, on) => {
  const cid = activeCustomer.value?.customer_id
  if (!cid) return
  if (!selectedCategories[cid]) selectedCategories[cid] = new Set()
  if (on) selectedCategories[cid].add(cat)
  else {
    selectedCategories[cid].delete(cat)
    // also remove any services under this category
    if (chosenServices[cid]?.[cat]) {
      delete chosenServices[cid][cat]
    }
  }
}

// Only show UNIT-scope services for the first customer (Phase 2: stricter)
const filteredServicesForActive = (cat) => {
  const list = servicesByCategory.value[cat] || []
  if (activeCustomerIndex.value > 0) {
    return list.filter(s => (s.service_scope || 'INDIVIDUAL') !== 'UNIT')
  }
  return list
}

const isServiceChosenForActive = (cat, service_id) => {
  const cid = activeCustomer.value?.customer_id
  if (!cid) return false
  return !!(chosenServices[cid]?.[cat]?.[service_id])
}

const ensureCategoryMap = (cid, cat) => {
  if (!chosenServices[cid]) chosenServices[cid] = {}
  if (!chosenServices[cid][cat]) chosenServices[cid][cat] = {}
}

const toggleServiceForActive = (cat, svc) => {
  const cid = activeCustomer.value?.customer_id
  if (!cid) return
  ensureCategoryMap(cid, cat)
  const present = !!chosenServices[cid][cat][svc.service_id]
  if (present) {
    delete chosenServices[cid][cat][svc.service_id]
    // Clear any exclusivity warnings for this service
    clearExclusivityWarnings(cid, svc.service_id)
  } else {
    // Check exclusivity BEFORE adding the service
    handleExclusivity(cid, cat, svc.service_id)
    
    // Add the service after exclusivity check
    chosenServices[cid][cat][svc.service_id] = {
      service_id: svc.service_id,
      service_name: svc.service_name,
      category: svc.service_category,
      service_scope: svc.service_scope || 'INDIVIDUAL',
      start_date: periodStart.value,
      end_date: periodEnd.value,
      specific_dates_text: '',
      time: '',
      location: svc._defaults.location,
      proof_required: svc._defaults.proof_required,
      special_instructions: svc._defaults.special_instructions
    }
    
    // Validate exclusivity rules for the newly added service
    validateServiceExclusivity(cid, svc.service_id)
  }
}

const cfgRef = (cid, cat, sid) => {
  if (!chosenServices[cid]) return null
  if (!chosenServices[cid][cat]) return null
  return chosenServices[cid][cat][sid] || null
}

const serviceCfg = (cid, cat, sid) => {
  const c = cfgRef(cid, cat, sid)
  // v-model protection
  if (!c) {
    ensureCategoryMap(cid, cat)
    chosenServices[cid][cat][sid] = {
      service_id: sid,
      service_name: '',
      category: cat,
      service_scope: 'INDIVIDUAL',
      start_date: periodStart.value,
      end_date: periodEnd.value,
      specific_dates_text: '',
      time: '',
      location: '',
      proof_required: false,
      special_instructions: ''
    }
    return chosenServices[cid][cat][sid]
  }
  return c
}

// Location options: default_delivery_location plus any unique locations across services
const locationOptionsFor = (svc) => {
  const base = []
  if (svc.default_delivery_location) base.push(svc.default_delivery_location)
  // Fallback: common defaults if none provided by master
  const commons = ['Unit', 'Dining Hall', 'Clinic', 'Office']
  for (const c of commons) if (!base.includes(c)) base.push(c)
  return base
}

// ──────────────────────────────────────────────────────────────────────────────
// Flow controls across customers in Step 4
// ──────────────────────────────────────────────────────────────────────────────
const copyFromPrevious = () => {
  if (activeCustomerIndex.value === 0) return
  const prevCid = selectedCustomers.value[activeCustomerIndex.value - 1].customer_id
  const cid = activeCustomer.value.customer_id

  // deep clone categories + services
  selectedCategories[cid] = new Set(selectedCategories[prevCid] ? Array.from(selectedCategories[prevCid]) : [])

  chosenServices[cid] = {}
  for (const cat of Object.keys(chosenServices[prevCid] || {})) {
    chosenServices[cid][cat] = { 
      ...JSON.parse(JSON.stringify(chosenServices[prevCid][cat])) 
    }
  }
  
  // Force Vue reactivity to refresh UI
  chosenServices[cid] = { ...chosenServices[cid] }
  selectedCategories[cid] = new Set([...selectedCategories[cid]])
}

const saveCurrentCustomerAndNext = () => {
  // basic validation: at least one service if any category chosen
  const cid = activeCustomer.value.customer_id
  const catCount = selectedCategories[cid]?.size || 0
  let chosenCount = 0
  if (catCount > 0) {
    for (const cat of selectedCategories[cid]) {
      chosenCount += Object.keys(chosenServices[cid]?.[cat] || {}).length
    }
  }
  if (catCount > 0 && chosenCount === 0) {
    return window.alert('You selected category(ies) but no services. Please add at least one service or unselect the category.')
  }

  // Validate exclusivity rules before proceeding
  validateActiveCustomerExclusivity()
  
  // Check for blocking exclusivity errors
  if (hasExclusivityErrors.value) {
    const blockingWarnings = getActiveCustomerExclusivityWarnings.value.filter(w => 
      w.type === 'resource_conflict' || w.type === 'location_conflict'
    )
    
    if (blockingWarnings.length > 0) {
      const errorMessage = 'Service conflicts detected:\n\n' + 
        blockingWarnings.map(w => `• ${w.message}`).join('\n') + 
        '\n\nPlease resolve these conflicts before proceeding.'
      return window.alert(errorMessage)
    }
  }

  // move to next customer or preview
  if (activeCustomerIndex.value < selectedCustomers.value.length - 1) {
    activeCustomerIndex.value++
  } else {
    buildLocalPreview()
    currentStep.value = 5
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Preview (client-side expansion)
// ──────────────────────────────────────────────────────────────────────────────
const buildLocalPreview = () => {
  previewRows.value = []
  if (!form.month) return

  const [y, m] = form.month.split('-').map(n => parseInt(n, 10))
  const daysInMonth = new Date(y, m, 0).getDate()

  const expandRange = (start, end) => {
    const out = []
    const s = parseInt(start.slice(-2), 10)
    const e = parseInt(end.slice(-2), 10)
    for (let d = s; d <= e; d++) out.push(d)
    return out
  }

  for (const cust of selectedCustomers.value) {
    const cid = cust.customer_id
    const catMap = chosenServices[cid] || {}
    for (const cat of Object.keys(catMap)) {
      const svcMap = catMap[cat]
      for (const sid of Object.keys(svcMap)) {
        const cfg = svcMap[sid]

        // Specific dates override date range
        let days = []
        const txt = (cfg.specific_dates_text || '').trim()
        if (txt) {
          days = txt.split(',')
            .map(s => s.trim())
            .filter(Boolean)
            .map(n => parseInt(n, 10))
            .filter(n => n >= 1 && n <= daysInMonth)
        } else if (cfg.start_date && cfg.end_date) {
          days = expandRange(cfg.start_date, cfg.end_date)
        }

        for (const d of days) {
          previewRows.value.push({
            date: `${form.month}-${String(d).padStart(2, '0')}`,
            customer_id: cid,
            customer_name: cust.full_name,
            category: cat,
            service_id: sid,
            service_name: cfg.service_name || sid,
            time: cfg.time,
            location: cfg.location,
            proof_required: cfg.proof_required
          })
        }
      }
    }
  }
}

const summarizedPreviewFor = (customerId) => {
  const grouped = {}
  for (const row of previewRows.value.filter(r => r.customer_id === customerId)) {
    const key = `${row.service_name}-${row.location || 'NA'}`
    if (!grouped[key]) grouped[key] = {
      service_name: row.service_name,
      category: row.category,
      location: row.location,
      time: row.time,
      proof_required: row.proof_required,
      min_date: row.date,
      max_date: row.date
    }
    grouped[key].min_date = grouped[key].min_date < row.date ? grouped[key].min_date : row.date
    grouped[key].max_date = grouped[key].max_date > row.date ? grouped[key].max_date : row.date
  }
  return Object.values(grouped).map(g => ({
    ...g,
    date_range: `${g.min_date} → ${g.max_date}`,
    key: `${g.service_name}-${g.location}`
  }))
}

const goToConfirm = () => {
  if (previewRows.value.length === 0) {
    return window.alert('No preview rows. Please configure at least one service occurrence.')
  }
  currentStep.value = 6
}

// ──────────────────────────────────────────────────────────────────────────────
// Submit
// ──────────────────────────────────────────────────────────────────────────────
// Helper to format axios errors for readable alerts
function formatAxiosError(err) {
  if (err.response) {
    // Server responded with a status code out of 2xx
    let detail = ''
    if (typeof err.response.data === 'string') detail = err.response.data
    else detail = JSON.stringify(err.response.data)
    return `Status: ${err.response.status}\n${detail}`
  } else if (err.request) {
    // Request made but no response received
    return `No response received.\n${err.message}`
  } else {
    // Something else happened
    return err.message
  }
}

const submitAll = async () => {
  // Phase 2: Guard - ensure all customers belong to the same unit
  const invalidCustomer = selectedCustomers.value.find(c => c.unit_id && c.unit_id !== form.unit_id)
  if (invalidCustomer) {
    window.alert('Error: Customers from multiple units cannot be saved in the same subscription.')
    return
  }
  try {
    const payload = buildPayload()
    console.log('[SUBMIT] POST /subscription_requests payload', payload)
    await axios.post(`${API}/subscription_requests`, payload, { headers: { 'Content-Type': 'application/json' } })
    window.alert('Subscription saved for approval. It will be activated after supervisor approval.')
    // reset
    resetAll()
  } catch (err) {
    console.error('[SUBMIT] Save failed', err)
    window.alert('Failed to save subscription.\n' + formatAxiosError(err))
  }
}

const buildPayload = () => {
  // master (period derived from month)
  const [y, m] = form.month.split('-').map(n => parseInt(n, 10))
  const period_start = periodStart.value
  const period_end = periodEnd.value

  const master = {
    unit_id: form.unit_id,
    period_start,
    period_end,
    created_by: 'userabc',   // placeholder (later: real auth)
    status: 'DRAFT'
  }

  // link customers
  const subCustomers = selectedCustomers.value.map(c => ({
    customer_id: c.customer_id
  }))

  // lines
  const lines = []
  for (const cust of selectedCustomers.value) {
    const cid = cust.customer_id
    for (const cat of Object.keys(chosenServices[cid] || {})) {
      for (const sid of Object.keys(chosenServices[cid][cat] || {})) {
        const cfg = chosenServices[cid][cat][sid]
        // convert specific_dates_text to array (numbers)
        const specific_dates = (cfg.specific_dates_text || '')
          .split(',')
          .map(s => s.trim())
          .filter(Boolean)
          .map(n => parseInt(n, 10))

        lines.push({
          customer_id: cfg.service_scope === 'UNIT' ? null : cid,
          service_id: sid,
          category: cat,
          service_scope: cfg.service_scope || 'INDIVIDUAL',
          start_date: cfg.start_date || null,
          end_date: cfg.end_date || null,
          specific_dates,
          time: cfg.time || null,
          location: cfg.location || null,
          proof_required: !!cfg.proof_required,
          special_instructions: cfg.special_instructions || null
        })
      }
    }
  }

  return {
    ...master,
    payload: {
      customers: subCustomers,
      lines
    }
  }
}

const resetAll = () => {
  if (!window.confirm('Clear all selections and start over?')) return
  currentStep.value = 1
  form.month = ''
  form.unit_id = ''
  selectedCustomers.value = []
  activeCustomerIndex.value = 0
  servicesRaw.value = []
  servicesByCategory.value = {}
  for (const k of Object.keys(selectedCategories)) delete selectedCategories[k]
  for (const k of Object.keys(chosenServices)) delete chosenServices[k]
  previewRows.value = []
}

// ──────────────────────────────────────────────────────────────────────────────
// Real-time Exclusivity Validation
// ──────────────────────────────────────────────────────────────────────────────

// Watch for changes in service configurations and validate exclusivity
watch(
  () => chosenServices,
  () => {
    const cid = activeCustomer.value?.customer_id
    if (cid) {
      // Debounce validation to avoid excessive calls
      setTimeout(() => {
        validateActiveCustomerExclusivity()
      }, 500)
    }
  },
  { deep: true }
)

// Watch for active customer changes and validate
watch(
  () => activeCustomer.value?.customer_id,
  (newCustomerId) => {
    if (newCustomerId) {
      validateActiveCustomerExclusivity()
    }
  }
)

// ──────────────────────────────────────────────────────────────────────────────
// Test Functions for Exclusivity Rules (Development/Demo)
// ──────────────────────────────────────────────────────────────────────────────

/**
 * Test function to demonstrate exclusivity rules
 * This can be called from browser console for testing
 */
const testExclusivityRules = () => {
  console.log('Testing Exclusivity Rules Engine...')
  
  // Test time conflict detection
  const timeConflict = ExclusivityEngine.checkTimeConflicts('BREAKFAST', 'LUNCH', '08:00', '08:15')
  console.log('Time conflict test (BREAKFAST vs LUNCH at 08:00 vs 08:15):', timeConflict)
  
  // Test category conflict detection
  const categoryConflict = ExclusivityEngine.checkCategoryConflicts('CARE (Housekeeping)', 'CARE (Laundry)', 'UNIT')
  console.log('Category conflict test (Housekeeping vs Laundry):', categoryConflict)
  
  // Test resource conflict detection
  const resourceConflict = ExclusivityEngine.checkResourceConflicts('AMBULANCE', 'TAXI_SERVICE')
  console.log('Resource conflict test (AMBULANCE vs TAXI_SERVICE):', resourceConflict)
  
  // Test location conflict detection
  const locationConflict = ExclusivityEngine.checkLocationConflicts('MEAL_SERVICE', 'SPECIAL_EVENT', 'Dining Hall', 'Dining Hall')
  console.log('Location conflict test (MEAL_SERVICE vs SPECIAL_EVENT in Dining Hall):', locationConflict)
  
  console.log('Exclusivity Rules Engine test completed.')
}

// Make test function available globally for development
if (typeof window !== 'undefined') {
  window.testExclusivityRules = testExclusivityRules
}

// ──────────────────────────────────────────────────────────────────────────────
// Lifecycle & Watches
// ──────────────────────────────────────────────────────────────────────────────
onMounted(async () => {
  await loadUnits()
})

// Watch for unit selection and reset state when unit changes
watch(
  () => form.unit_id,
  (newVal, oldVal) => {
    // Clear selected customers if unit changes
    if (oldVal && newVal !== oldVal) {
      selectedCustomers.value = []
      customers.value = []
      // Reset to step 2 if we're on a later step
      if (currentStep.value > 2) {
        currentStep.value = 2
      }
    }
  }
)

// Automatically load customers when a unit is selected
watch(
  () => form.unit_id,
  async (newVal, oldVal) => {
    if (!newVal) return;

    // If the unit changed, reset previous selections
    if (oldVal && newVal !== oldVal) {
      selectedCustomers.value = [];
      customers.value = [];
    }

    try {
      await loadCustomers();
    } catch (err) {
      console.error('Failed to auto-load customers for unit:', newVal, err);
    }
  }
);
const goToTeamReport = () => {
  window.open('http://localhost:5173/team-report', '_blank')
}

const openReportsDashboard = () => {
  window.open('http://localhost:5173/reports-dashboard', '_blank')
}
</script>

<style scoped>
.input {
  @apply border rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400;
}
.label {
  @apply block text-sm font-medium text-gray-700 mb-1;
}
.btn-primary {
  @apply bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700;
}
.btn-secondary {
  @apply bg-gray-200 text-gray-800 px-4 py-2 rounded hover:bg-gray-300;
}
.th { @apply text-left px-2 py-2 text-gray-700; }
.td { @apply px-2 py-2; }
</style>

<style scoped>
/* Spreadsheet-style table for Step 2 and services, thin borders, small font, consistent spacing */
.spreadsheet-table {
  border-collapse: collapse;
  font-size: 13px;
}
.spreadsheet-table th,
.spreadsheet-table td {
  border: 1px solid #d1d5db;
  padding: 0.35rem 0.5rem;
  font-size: 13px;
}
.spreadsheet-table th {
  background: #f9fafb;
  font-weight: 600;
  color: #374151;
}
.spreadsheet-table tr:nth-child(even) {
  background: #f6f7fa;
}
</style>